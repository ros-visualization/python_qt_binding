cmake_minimum_required(VERSION 2.8)
project(python_qt_bindings)
find_package(catkin)
catkin_stack()
catkin_project(python_qt_bindings)

#install targets for all things python
catkin_python_setup()

install(DIRECTORY cmake
        DESTINATION ${CATKIN_PROJECT_SHARE_DESTINATION}
        COMPONENT main
)

