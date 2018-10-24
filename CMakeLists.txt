cmake_minimum_required(VERSION 3.5)
project(python_qt_binding)

find_package(ament_cmake REQUIRED)
find_package(ament_cmake_python REQUIRED)

ament_python_install_package(${PROJECT_NAME}
  PACKAGE_DIR src/${PROJECT_NAME})

install(FILES
  cmake/shiboken_helper.cmake
  cmake/sip_configure.py
  cmake/sip_helper.cmake
  DESTINATION share/${PROJECT_NAME}/cmake)

  if(BUILD_TESTING)
    find_package(ament_cmake_pytest REQUIRED)
    find_package(ament_lint_auto REQUIRED)
    ament_lint_auto_find_test_dependencies()

    ament_add_pytest_test(pqt_test test
      APPEND_ENV
        PYTHONPATH=${CMAKE_CURRENT_BINARY_DIR}
      TIMEOUT 90
  )
  endif()

  ament_package(CONFIG_EXTRAS cmake/python_qt_binding-extras.cmake)
