^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Changelog for package python_qt_binding
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

0.2.17 (2015-09-19)
-------------------
* change import order of builtins to work when the 'future' package is installed in Python 2 (`#24 <https://github.com/ros-visualization/python_qt_binding/issues/24>`_)

0.2.16 (2015-05-04)
-------------------
* use qmake with QT_SELECT since qmake-qt4 is not available on all platforms (`#22 <https://github.com/ros-visualization/python_qt_binding/issues/22>`_)

0.2.15 (2015-04-23)
-------------------
* support PyQt4.11 and higher when built with configure-ng.py (`#13 <https://github.com/ros-visualization/python_qt_binding/issues/13>`_)
* __builtin__ became builtins in Python 3 (`#16 <https://github.com/ros-visualization/python_qt_binding/issues/16>`_)

0.2.14 (2014-07-10)
-------------------
* add Python_ADDITIONAL_VERSIONS and ask for specific version of PythonInterp
* fix finding specific version of PythonLibs with CMake 3 (`#11 <https://github.com/ros-visualization/python_qt_binding/issues/11>`_)
* fix sip_helper to use python header dirs on OS X (`#12 <https://github.com/ros-visualization/python_qt_binding/issues/12>`_)

0.2.13 (2014-05-07)
-------------------
* fix sip arguments when path contains spaces

0.2.12 (2014-01-08)
-------------------
* python 3 compatibility
* fix sip bindings when paths contain spaces (`#9 <https://github.com/ros-visualization/python_qt_binding/issues/9>`_)

0.2.11 (2013-08-21)
-------------------
* allow overriding binding order
* allow to release python_qt_binding as a standalone package to PyPI (`#5 <https://github.com/ros-visualization/python_qt_binding/issues/5>`_)

0.2.10 (2013-06-06)
-------------------
* refactor loadUi function to be documentable (`#2 <https://github.com/ros-visualization/python_qt_binding/issues/2>`_)

0.2.9 (2013-04-19)
------------------

0.2.8 (2013-01-13)
------------------

0.2.7 (2012-12-21)
------------------
* first public release for Groovy
