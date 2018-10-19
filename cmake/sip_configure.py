# Copyright (c) 2018
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from copy import copy
from distutils.spawn import find_executable
import os
import re
import subprocess
import sys

from PyQt5 import QtCore
import sipconfig


class Configuration(sipconfig.Configuration):

    def __init__(self):
        env = copy(os.environ)
        env['QT_SELECT'] = '5'
        qmake_exe = 'qmake-qt5' if find_executable('qmake-qt5') else 'qmake'
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
            'qt_winconfig': 'shared',
        }
        if sys.platform == 'darwin':
            pyqtconfig['qt_framework'] = 1
        sipconfig.Configuration.__init__(self, [pyqtconfig])

        macros = sipconfig._default_macros.copy()
        macros['INCDIR_QT'] = qtconfig['QT_INSTALL_HEADERS']
        macros['LIBDIR_QT'] = qtconfig['QT_INSTALL_LIBS']
        macros['MOC'] = 'moc-qt5'
        self.set_build_macros(macros)


if len(sys.argv) != 8:
    print('usage: %s build-dir sip-file output_dir include_dirs libs lib_dirs ldflags' %
          sys.argv[0])
    sys.exit(1)

# The SIP build folder, the SIP file, the output directory, the include directories, the libraries,
# the library directories and the linker flags.
build_dir, sip_file, output_dir, include_dirs, libs, lib_dirs, ldflags = sys.argv[1:]

# The name of the SIP build file generated by SIP and used by the build system.
build_file = 'pyqtscripting.sbf'

# Get the PyQt configuration information.
config = Configuration()

# Get the extra SIP flags needed by the imported qt module.  Note that
# this normally only includes those flags (-x and -t) that relate to SIP's
# versioning system.
try:
    sip_dir = config.pyqt_sip_dir
    sip_flags = config.pyqt_sip_flags
except AttributeError:
    # sipconfig.Configuration does not have a pyqt_sip_dir or pyqt_sip_flags attribute
    sip_dir = sipconfig._pkg_config['default_sip_dir'] + '/PyQt5'
    sip_flags = QtCore.PYQT_CONFIGURATION['sip_flags']

try:
    os.makedirs(build_dir)
except OSError:
    pass

# Run SIP to generate the code.  Note that we tell SIP where to find the qt
# module's specification files using the -I flag.
cmd = [
    config.sip_bin,
    '-c', build_dir,
    '-b', os.path.join(build_dir, build_file),
    '-I', sip_dir,
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

# hack to override makefile behavior which always prepend -l to libraries which is wrong for
# absolute paths
default_platform_lib_function = sipconfig.SIPModuleMakefile.platform_lib


def custom_platform_lib_function(self, clib, framework=0):
    if os.path.isabs(clib):
        return clib
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

# Force c++11 for qt5
makefile.extra_cxxflags.append('-std=c++11')

# Generate the Makefile itself
makefile.generate()
