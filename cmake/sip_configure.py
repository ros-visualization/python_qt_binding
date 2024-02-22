import copy
import os
import re
import shutil
import subprocess
import sys
import tempfile

import PyQt5
from PyQt5 import QtCore
import sipconfig

libqt5_rename = False


class Configuration(sipconfig.Configuration):

    def __init__(self):
        env = copy.copy(os.environ)
        env['QT_SELECT'] = '5'
        qmake_exe = 'qmake-qt5' if shutil.which('qmake-qt5') else 'qmake'
        qtconfig = subprocess.check_output(
            [qmake_exe, '-query'], env=env, universal_newlines=True)
        qtconfig = dict(line.split(':', 1) for line in qtconfig.splitlines())
        pyqtconfig = {
            'qt_archdata_dir': qtconfig['QT_INSTALL_DATA'],
            'qt_data_dir': qtconfig['QT_INSTALL_DATA'],
            'qt_dir': qtconfig['QT_INSTALL_PREFIX'],
            'qt_inc_dir': qtconfig['QT_INSTALL_HEADERS'],
            'qt_lib_dir': qtconfig['QT_INSTALL_LIBS'],
            'qt_threaded': 1,
            'qt_version': QtCore.QT_VERSION,
            'qt_winconfig': 'shared exceptions',
        }
        if sys.platform == 'darwin':
            if os.path.exists(os.path.join(qtconfig['QT_INSTALL_LIBS'], 'QtCore.framework')):
                pyqtconfig['qt_framework'] = 1
            else:
                global libqt5_rename
                libqt5_rename = True

        sipconfig.Configuration.__init__(self, [pyqtconfig])

        macros = sipconfig._default_macros.copy()
        macros['INCDIR_QT'] = qtconfig['QT_INSTALL_HEADERS']
        macros['LIBDIR_QT'] = qtconfig['QT_INSTALL_LIBS']
        macros['MOC'] = 'moc-qt5' if shutil.which('moc-qt5') else 'moc'
        self.set_build_macros(macros)


def get_sip_dir_flags(config):
    """
    Get the extra SIP flags needed by the imported qt module, and locate PyQt5 sip install files.

    Note that this normally only includes those flags (-x and -t) that relate to SIP's versioning
    system.
    """
    try:
        sip_dir = config.pyqt_sip_dir
        sip_flags = config.pyqt_sip_flags
        return sip_dir, sip_flags
    except AttributeError:
        pass

    # We didn't find the sip_dir and sip_flags from the config, continue looking

    # sipconfig.Configuration does not have a pyqt_sip_dir or pyqt_sip_flags AttributeError
    sip_flags = QtCore.PYQT_CONFIGURATION['sip_flags']

    candidate_sip_dirs = []

    # Archlinux installs sip files here by default
    candidate_sip_dirs.append(os.path.join(PyQt5.__path__[0], 'bindings'))

    # sip4 installs here by default
    candidate_sip_dirs.append(os.path.join(sipconfig._pkg_config['default_sip_dir'], 'PyQt5'))

    # Homebrew installs sip files here by default
    candidate_sip_dirs.append(os.path.join(sipconfig._pkg_config['default_sip_dir'], 'Qt5'))

    for sip_dir in candidate_sip_dirs:
        if os.path.exists(sip_dir):
            return sip_dir, sip_flags

    raise FileNotFoundError('The sip directory for PyQt5 could not be located. Please ensure' +
                            ' that PyQt5 is installed')


if len(sys.argv) != 8:
    print('usage: %s build-dir sip-file output_dir include_dirs libs lib_dirs ldflags' %
          sys.argv[0])
    sys.exit(1)

# The SIP build folder, the SIP file, the output directory, the include
# directories, the libraries, the library directories and the linker
# flags.
build_dir, sip_file, output_dir, include_dirs, libs, lib_dirs, ldflags = sys.argv[1:]

# The name of the SIP build file generated by SIP and used by the build system.
build_file = 'pyqtscripting.sbf'

# Get the PyQt configuration information.
config = Configuration()

sip_dir, sip_flags = get_sip_dir_flags(config)

try:
    os.makedirs(build_dir)
except OSError:
    pass

# Run SIP to generate the code.  Note that we tell SIP where to find the qt
# module's specification files using the -I flag.

sip_bin = config.sip_bin
# Without the .exe, this might actually be a directory in Windows
if sys.platform == 'win32' and os.path.isdir(sip_bin):
    sip_bin += '.exe'

# SIP4 has an incompatibility with Qt 5.15.6.  In particular, Qt 5.15.6 uses a new SIP directive
# called py_ssize_t_clean in QtCoremod.sip that SIP4 does not understand.
#
# Unfortunately, the combination of SIP4 and Qt 5.15.6 is common.  Archlinux, Ubuntu 22.04
# and RHEL-9 all have this combination.  On Ubuntu 22.04, there is a custom patch to SIP4
# to make it understand the py_ssize_t_clean tag, so the combination works.  But on most
# other platforms, it fails.
#
# To workaround this, copy all of the SIP files into a temporary directory, remove the offending
# line, and then use that temporary directory as the include path.  This is unnecessary on
# Ubuntu 22.04, but shouldn't hurt anything there.
with tempfile.TemporaryDirectory() as tmpdirname:
    shutil.copytree(sip_dir, tmpdirname, dirs_exist_ok=True)

    output = ''
    with open(os.path.join(tmpdirname, 'QtCore', 'QtCoremod.sip'), 'r') as infp:
        for line in infp:
            if line.startswith('%Module(name='):
                result = re.sub(r', py_ssize_t_clean=True', '', line)
                output += result
            else:
                output += line

    with open(os.path.join(tmpdirname, 'QtCore', 'QtCoremod.sip'), 'w') as outfp:
        outfp.write(output)

    cmd = [
        sip_bin,
        '-c', build_dir,
        '-b', os.path.join(build_dir, build_file),
        '-I', tmpdirname,
        '-w'
    ]
    cmd += sip_flags.split(' ')
    cmd.append(sip_file)

    subprocess.check_call(cmd)

# Create the Makefile.  The QtModuleMakefile class provided by the
# pyqtconfig module takes care of all the extra preprocessor, compiler and
# linker flags needed by the Qt library.
makefile = sipconfig.SIPModuleMakefile(
    dir=build_dir,
    configuration=config,
    build_file=build_file,
    qt=['QtCore', 'QtGui']
)

# hack to override makefile behavior which always prepend -l to libraries
# which is wrong for absolute paths
default_platform_lib_function = sipconfig.SIPModuleMakefile.platform_lib


def custom_platform_lib_function(self, clib, framework=0):
    if not clib or clib.isspace():
        return None
    # Only add '-l' if a library doesn't already start with '-l' and is not an absolute path
    if os.path.isabs(clib) or clib.startswith('-l'):
        return clib

    global libqt5_rename
    # sip renames libs to Qt5 automatically on Linux, but not on macOS
    if libqt5_rename and not framework and clib.startswith('Qt') and not clib.startswith('Qt5'):
        return '-lQt5' + clib[2:]

    return default_platform_lib_function(self, clib, framework)


sipconfig.SIPModuleMakefile.platform_lib = custom_platform_lib_function


# split paths on whitespace
# while dealing with whitespaces within the paths if they are escaped with backslashes
def split_paths(paths):
    paths = re.split('(?<=[^\\\\]) ', paths)
    return paths


for include_dir in split_paths(include_dirs):
    include_dir = include_dir.replace('\\', '')
    makefile.extra_include_dirs.append(include_dir)
for lib in split_paths(libs):
    makefile.extra_libs.append(lib)
for lib_dir in split_paths(lib_dirs):
    lib_dir = lib_dir.replace('\\', '')
    makefile.extra_lib_dirs.append(lib_dir)
for ldflag in ldflags.split('\\ '):
    makefile.LFLAGS.append(ldflag)

# redirect location of generated library
makefile._target = '"%s"' % os.path.join(output_dir, makefile._target)

# Force c++17
if sys.platform == 'win32':
    makefile.extra_cxxflags.append('/std:c++17')
    # The __cplusplus flag is not properly set on Windows for backwards
    # compatibilty. This flag sets it correctly
    makefile.CXXFLAGS.append('/Zc:__cplusplus')
else:
    makefile.extra_cxxflags.append('-std=c++17')

# Finalise the Makefile, preparing it to be saved to disk
makefile.finalise()

# Replace Qt variables from libraries
libs = makefile.LIBS.as_list()
for i in range(len(libs)):
    libs[i] = libs[i].replace('$$[QT_INSTALL_LIBS]', config.build_macros()['LIBDIR_QT'])
makefile.LIBS.set(libs)

# Generate the Makefile itself
makefile.generate()
