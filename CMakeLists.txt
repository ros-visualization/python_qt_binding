cmake_minimum_required(VERSION 3.20)
project(python_qt_binding)

find_package(ament_cmake REQUIRED)
find_package(ament_cmake_python REQUIRED)

# Copy python package into binary directory
file(COPY src/${PROJECT_NAME} DESTINATION ${CMAKE_CURRENT_BINARY_DIR})

include(python_qt_binding-extras.cmake)

# Generate a version.py file inside the copied package directory
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/version.py
  "QT_MAJOR_VERSION = ${python_qt_binding_QT_MAJOR_VERSION}\n"
)

# Install the package from the binary directory
ament_python_install_package(${PROJECT_NAME}
  PACKAGE_DIR ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME})

install(FILES
  cmake/pyproject.toml.in
  cmake/shiboken_helper.cmake
  cmake/sip_helper.cmake
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

ament_package(
  CONFIG_EXTRAS "python_qt_binding-extras.cmake"
)
