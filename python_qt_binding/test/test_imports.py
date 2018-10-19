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

import unittest


class TestImports(unittest.TestCase):

    def test_import_qtcore(self):
        from python_qt_binding import QtCore
        self.assertTrue(QtCore is not None)

    def test_import_qtgui(self):
        from python_qt_binding import QtGui
        self.assertTrue(QtGui is not None)

    def test_import_qtwidgets(self):
        from python_qt_binding import QtWidgets
        self.assertTrue(QtWidgets is not None)

    def test_import_qtobject(self):
        from python_qt_binding.QtCore import QtObject
        self.assertTrue(QtObject is not None)
