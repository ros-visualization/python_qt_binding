cmake_minimum_required(VERSION 2.8)
project(python_qt_binding)
find_package(catkin)
catkin_stack()
catkin_project(${PROJECT_NAME})

catkin_python_setup()

install(DIRECTORY cmake
  DESTINATION ${CATKIN_PROJECT_SHARE_DESTINATION}
)
