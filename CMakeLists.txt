cmake_minimum_required(VERSION 2.8)
project(python_qt_binding)

find_package(catkin REQUIRED)
catkin_package(CFG_EXTRAS python_qt_binding-extras.cmake)

catkin_python_setup()

install(DIRECTORY cmake
        DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
)
