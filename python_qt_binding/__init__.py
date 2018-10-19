#!/usr/bin/env python

# Copyright 2015 Open Source Robotics Foundation, Inc.
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

"""
Abstraction for different Python Qt bindings.

Supported Python Qt 5 bindings are PyQt and PySide.
The Qt modules can be imported like this:

from python_qt_binding.QtCore import QObject
from python_qt_binding import QtGui, loadUi

The name of the selected binding is available in QT_BINDING.
The version of the selected binding is available in QT_BINDING_VERSION.
All available Qt modules are listed in QT_BINDING_MODULES.

The default binding order ('pyqt', 'pyside') can be overridden with a
SELECT_QT_BINDING_ORDER attribute on sys:
  setattr(sys, 'SELECT_QT_BINDING_ORDER', [FIRST_NAME, NEXT_NAME, ..])

A specific binding can be selected with a SELECT_QT_BINDING attribute on sys:
  setattr(sys, 'SELECT_QT_BINDING', MY_BINDING_NAME)
"""

import sys

from python_qt_binding.binding_helper import QT_BINDING_MODULES

# register binding modules as sub modules of this package (python_qt_binding) for easy importing
for module_name, module in QT_BINDING_MODULES.items():
    sys.modules[__name__ + '.' + module_name] = module
    setattr(sys.modules[__name__], module_name, module)
    del module_name
    del module

del sys
