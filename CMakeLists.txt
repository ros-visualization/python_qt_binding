cmake_minimum_required(VERSION 3.5)
project(python_qt_binding)

find_package(ament_cmake REQUIRED)
find_package(ament_cmake_python REQUIRED)

ament_python_install_package(${PROJECT_NAME})

install(TARGETS ${_library_name}
  DESTINATION "${PYTHON_INSTALL_DIR}/${PROJECT_NAME}"
)

set(python_qt_binding_CMAKE_DIRS cmake)
install(FILES
  cmake/shiboken_helper.cmake
  cmake/sip_configure.py
  cmake/sip_helper.cmake
  DESTINATION share/${PROJECT_NAME}/cmake/)

  if(BUILD_TESTING)
    find_package(ament_cmake_pytest REQUIRED)
    find_package(ament_lint_auto REQUIRED)
    ament_lint_auto_find_test_dependencies()

    ament_add_pytest_test(pqt_test test
      PYTHON_EXECUTABLE "${PYTHON_EXECUTABLE}"
      APPEND_ENV AMENT_PREFIX_PATH=${ament_index_build_path}
        PYTHONPATH=${CMAKE_CURRENT_BINARY_DIR}
      TIMEOUT 90
  )
  endif()

  ament_package(CONFIG_EXTRAS cmake/python_qt_binding-extras.cmake)
