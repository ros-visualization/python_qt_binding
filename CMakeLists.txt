cmake_minimum_required(VERSION 3.5)
project(python_qt_binding)

find_package(ament_cmake REQUIRED)
find_package(ament_cmake_python REQUIRED)

ament_python_install_package(${PROJECT_NAME})

install(TARGETS ${_library_name}
  DESTINATION "${PYTHON_INSTALL_DIR}/${PROJECT_NAME}"
)

install(FILES
  cmake/shiboken_helper.cmake
  cmake/sip_configure.py
  cmake/sip_helper.cmake
  DESTINATION $SHARE_PYTHON_QT_BINDING)

  ament_package(CONFIG_EXTRAS cmake/python_qt_binding-extras.cmake)
