^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Changelog for package python_qt_binding
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

2.1.1 (2024-02-07)
------------------
* Remove unnecessary parentheses around assert. (`#133 <https://github.com/ros-visualization/python_qt_binding/issues/133>`_)
* Contributors: Chris Lalancette

2.1.0 (2024-01-24)
------------------
* Switch to FindPython3 in the shiboken_helper.cmake. (`#132 <https://github.com/ros-visualization/python_qt_binding/issues/132>`_)
* Contributors: Chris Lalancette

2.0.0 (2023-12-26)
------------------
* Cleanup of the sip_configure.py file. (`#131 <https://github.com/ros-visualization/python_qt_binding/issues/131>`_)
* Update the SIP support so we can deal with a broken RHEL-9. (`#129 <https://github.com/ros-visualization/python_qt_binding/issues/129>`_)
* Contributors: Chris Lalancette

1.3.0 (2023-04-28)
------------------

1.2.3 (2023-04-11)
------------------
* Fix to allow ninja to use make for generators (`#123 <https://github.com/ros-visualization/python_qt_binding/issues/123>`_)
* Fix flake8 linter regression (`#125 <https://github.com/ros-visualization/python_qt_binding/issues/125>`_)
* Remove pyqt from default binding order for macOS (`#118 <https://github.com/ros-visualization/python_qt_binding/issues/118>`_)
* Contributors: Christoph Hellmann Santos, Cristóbal Arroyo, Michael Carroll, Rhys Mainwaring

1.2.2 (2023-02-24)
------------------
* Demote missing SIP message from WARNING to STATUS (`#122 <https://github.com/ros-visualization/python_qt_binding/issues/122>`_)
* Contributors: Scott K Logan

1.2.1 (2023-02-14)
------------------
* [rolling] Update maintainers - 2022-11-07 (`#120 <https://github.com/ros-visualization/python_qt_binding/issues/120>`_)
* Contributors: Audrow Nash

1.2.0 (2022-05-10)
------------------

1.1.1 (2021-12-06)
------------------
* Replace PythonInterp to Python3 COMPONENTS (`#108 <https://github.com/ros-visualization/python_qt_binding/issues/108>`_)
* Use PyQt5 module path to find SIP bindings (`#106 <https://github.com/ros-visualization/python_qt_binding/issues/106>`_)
* Contributors: Ben Wolsieffer, Homalozoa X

1.1.0 (2021-11-02)
------------------
* Make FindPythonInterp dependency explicit (`#107 <https://github.com/ros-visualization/python_qt_binding/issues/107>`_)
* Add note about galactic branch (`#104 <https://github.com/ros-visualization/python_qt_binding/issues/104>`_)
* fuerte-devel is too new for ROS Electric (`#101 <https://github.com/ros-visualization/python_qt_binding/issues/101>`_)
* Contributors: Shane Loretz

1.0.7 (2021-03-18)
------------------
* Add repo README
* Shorten some long lines of CMake (`#99 <https://github.com/ros-visualization/python_qt_binding/issues/99>`_)
* Contributors: Scott K Logan, Shane Loretz

1.0.6 (2021-01-25)
------------------
* Update maintainers (`#96 <https://github.com/ros-visualization/python_qt_binding/issues/96>`_) (`#98 <https://github.com/ros-visualization/python_qt_binding/issues/98>`_)
* Add pytest.ini so local tests don't display warning (`#93 <https://github.com/ros-visualization/python_qt_binding/issues/93>`_)
* Contributors: Chris Lalancette, Shane Loretz

1.0.5 (2020-05-26)
------------------
* allow a list of INCLUDE_PATH (`#92 <https://github.com/ros-visualization/python_qt_binding/issues/92>`_)
* Use magic $(MAKE) variable to suppress build warning (`#91 <https://github.com/ros-visualization/python_qt_binding/issues/91>`_)
* Fix linking with non framework builds of qt (e.g. from conda-forge) (`#84 <https://github.com/ros-visualization/python_qt_binding/issues/84>`_)
* Contributors: Anton Matosov, Dirk Thomas, Robert Haschke

1.0.4 (2020-05-05)
------------------
* remove obsolete function used for backward compatibility (`#88 <https://github.com/ros-visualization/python_qt_binding/issues/88>`_)
* disable Shiboken with CMake < 3.14 (`#87 <https://github.com/ros-visualization/python_qt_binding/issues/87>`_)
* fix case of CMake function (`#86 <https://github.com/ros-visualization/python_qt_binding/issues/86>`_)
* restore QUIET which was reverted in `#79 <https://github.com/ros-visualization/python_qt_binding/issues/79>`_
* use PySide2 and Shiboken2 targets for variables (`#79 <https://github.com/ros-visualization/python_qt_binding/issues/79>`_)
* Contributors: Dirk Thomas, Hermann von Kleist

1.0.3 (2019-11-12)
------------------
* check if Shiboken2Config.cmake defines a target instead of a variable (`#77 <https://github.com/ros-visualization/python_qt_binding/issues/77>`_)

1.0.2 (2019-09-30)
------------------
* replace Qt variable in generated Makefile (`#64 <https://github.com/ros-visualization/python_qt_binding/issues/64>`_)
* don't add -l prefix if it already exists (`#59 <https://github.com/ros-visualization/python_qt_binding/issues/59>`_)
* if present, use the sipconfig suggested sip program (`#70 <https://github.com/ros-visualization/python_qt_binding/issues/70>`_)
* replace Qt variable in generated Makefile (`#64 <https://github.com/ros-visualization/python_qt_binding/issues/64>`_) (`#67 <https://github.com/ros-visualization/python_qt_binding/issues/67>`_)
* fixing trivial accidental string concatenation (`#66 <https://github.com/ros-visualization/python_qt_binding/issues/66>`_)

1.0.1 (2018-12-11)
------------------
* no warnings for unavailable PySide/Shiboken (`#58 <https://github.com/ros-visualization/python_qt_binding/issues/58>`_)

1.0.0 (2018-12-10)
------------------
* check for Homebrew's PyQt5 install path (`#57 <https://github.com/ros-visualization/python_qt_binding/issues/57>`_)
* port to Windows (`#56 <https://github.com/ros-visualization/python_qt_binding/issues/56>`_)
* fix lint tests (`#55 <https://github.com/ros-visualization/python_qt_binding/issues/55>`_)
* update sip_configure to handle improper lib names (`#54 <https://github.com/ros-visualization/python_qt_binding/issues/54>`_)
* port to ROS 2 (`#52 <https://github.com/ros-visualization/python_qt_binding/issues/52>`_)
* autopep8 (`#51 <https://github.com/ros-visualization/python_qt_binding/issues/51>`_)
* remove :: from shiboken include path (`#48 <https://github.com/ros-visualization/python_qt_binding/issues/48>`_)

0.3.4 (2018-08-03)
------------------
* add support for additional Qt5 modules (`#45 <https://github.com/ros-visualization/python_qt_binding/issues/45>`_)

0.3.3 (2017-10-25)
------------------
* Prefer qmake-qt5 over qmake when available (`#43 <https://github.com/ros-visualization/python_qt_binding/issues/43>`_)

0.3.2 (2017-01-23)
------------------
* Fix problems on OS X (`#40 <https://github.com/ros-visualization/python_qt_binding/pull/40>`_)

0.3.1 (2016-04-21)
------------------
* support for the Qt 5 modules QtWebEngine and QtWebKitWidgets (`#37 <https://github.com/ros-visualization/python_qt_binding/issues/37>`_)

0.3.0 (2016-04-01)
------------------
* switch to Qt5 (`#30 <https://github.com/ros-visualization/python_qt_binding/issues/30>`_)
* print full stacktrace

0.2.18 (2016-03-17)
-------------------
* remove LGPL and GPL from licenses, all code is BSD (`#27 <https://github.com/ros-visualization/python_qt_binding/issues/27>`_)

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
