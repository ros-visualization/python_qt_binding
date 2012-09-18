from __future__ import print_function
from .binding_helper import loadUi, QT_BINDING, QT_BINDING_MODULES, QT_BINDING_VERSION  # @UnusedImport

print('Deprecation warning: the "python_qt_binding.QtBindingHelper" module is deprecated and will be removed in the near future.')
print('Replace your usage of QtBindingHelper with import statements like:')
print('  from python_qt_binding.QtCore import QObject')
print('  from python_qt_binding import QtGui, loadUi')
