cmake_minimum_required(VERSION 3.5)
project(python_qt_binding)

find_package(ament_cmake REQUIRED)
find_package(ament_cmake_python REQUIRED)
find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Widgets)

if (${QT_VERSION_MAJOR} GREATER "5")
  ament_python_install_package(python_qt_binding
    PACKAGE_DIR src/python_qt6_binding)
else()
  ament_python_install_package(python_qt_binding
    PACKAGE_DIR src/python_qt_binding
  )
endif()

install(FILES
  cmake/pyproject.toml.in
  cmake/shiboken_helper.cmake
  cmake/sip_configure.py
  cmake/sip_helper.cmake
  cmake/pyside_config.py
  DESTINATION share/${PROJECT_NAME}/cmake)

if(BUILD_TESTING)
  find_package(ament_cmake_pytest REQUIRED)
  find_package(ament_lint_auto REQUIRED)

  # Disabling copyright test. The copyright used in this package does not conform to
  # ament's copyright tests
  set(ament_cmake_copyright_FOUND TRUE)
  ament_lint_auto_find_test_dependencies()

  ament_add_pytest_test(python_qt_binding test
    APPEND_ENV PYTHONPATH=${CMAKE_CURRENT_BINARY_DIR}
    TIMEOUT 90)
endif()

ament_package()
