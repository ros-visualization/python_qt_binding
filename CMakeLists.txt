cmake_minimum_required(VERSION 3.0.2)
project(python_qt_binding)

find_package(catkin REQUIRED)
catkin_package(CFG_EXTRAS python_qt_binding-extras.cmake)

catkin_python_setup()

install(FILES
  cmake/shiboken_helper.cmake
  cmake/sip_configure.py
  cmake/sip_helper.cmake
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}/cmake)
