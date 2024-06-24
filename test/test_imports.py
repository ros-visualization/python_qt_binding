# Copyright 2018, PickNik Consulting
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

import importlib.machinery
import sys

import pytest


# If this is running on a Python Windows interpreter built in debug mode, skip running tests
# because we do not have the debug libraries available for PyQt.  It is surprisingly tricky to
# discover whether the current interpreter was built in debug mode (note that this is different
# than running the interpreter in debug mode, i.e. PYTHONDEBUG=1).  The only non-deprecated way
# we've found is to look for _d.pyd in the extension suffixes, so that is what we do here.
is_windows_debug = sys.platform == 'win32' and '_d.pyd' in importlib.machinery.EXTENSION_SUFFIXES


@pytest.mark.skipif(is_windows_debug, reason='Skipping test on Windows Debug')
def test_import_qtcore():
    from python_qt_binding import QtCore
    assert QtCore is not None


@pytest.mark.skipif(is_windows_debug, reason='Skipping test on Windows Debug')
def test_import_qtgui():
    from python_qt_binding import QtGui
    assert QtGui is not None


@pytest.mark.skipif(is_windows_debug, reason='Skipping test on Windows Debug')
def test_import_qtwidgets():
    from python_qt_binding import QtWidgets
    assert QtWidgets is not None


@pytest.mark.skipif(is_windows_debug, reason='Skipping test on Windows Debug')
def test_import_qtobject():
    from python_qt_binding.QtCore import QObject
    assert QObject is not None
