#!/usr/bin/env python

# Copyright (c) 2015, Jesper Friis, SINTEF Materials and Chemistry
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#   * Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#   * Redistributions in binary form must reproduce the above
#     copyright notice, this list of conditions and the following
#     disclaimer in the documentation and/or other materials provided
#     with the distribution.
#   * Neither the name of the TU Darmstadt nor the names of its
#     contributors may be used to endorse or promote products derived
#     from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

"""A module for compiling and importing qrc files on the fly.

Example use:

    from python_qt_binding.loadqrc import loadqrc
    loadqrc('myresource.qrc')

Should work for both Python 2 and 3.
"""
import sys
import os
import imp
import subprocess

from .binding_helper import QT_BINDING, QT_BINDING_VERSION


def import_from_string(module_name, string):
    """Imports `string` as a module with name `module_name`.

    A reference to the module is returned.
    """
    if module_name in sys.modules:
        return

    # Create new module
    newmodule = imp.new_module(module_name)
    if sys.version_info.major < 3:
        exec('exec string in newmodule.__dict__')
    else:
        exec(string, newmodule.__dict__)
    
    # Add it to sys.modules to ignore any new attemp to import
    sys.modules[module_name] = newmodule

    return newmodule


def loadqrc(qrcfile, rcc=None):
    """Compiles `qrcfile` on the fly and imports it.  A reference to the
    new module is returned.

    The resource compiler is determined from the current qt bindings and
    python version, but can be specified manually with the rcc argument.
    """
    module_name = os.path.splitext(os.path.basename(qrcfile))[0]
    if module_name in sys.modules:
        return sys.modules[module_name]

    if not rcc:
        if QT_BINDING == 'pyqt':
            rcc = 'pyrcc4' if QT_BINDING_VERSION.startswith('4') else 'pyrcc'
        elif QT_BINDING == 'pyside':
            rcc = 'pyside-rcc'
        else:
            raise ValueError(
                '`qt_binding` must be either "pyqt" or "pyside. Got %r"' %
                qt_binding)

    cmd = '%s -py%d %s' % (rcc, sys.version_info.major, qrcfile)
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
    string = p.communicate()[0]
    return import_from_string(module_name, string)

    
        
