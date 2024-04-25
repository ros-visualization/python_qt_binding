# By default, without the settings below, find_package(Python3) will attempt
# to find the newest python version it can, and additionally will find the
# most specific version.  For instance, on a system that has
# /usr/bin/python3.10, /usr/bin/python3.11, and /usr/bin/python3, it will find
# /usr/bin/python3.11, even if /usr/bin/python3 points to /usr/bin/python3.10.
# The behavior we want is to prefer the "system" installed version unless the
# user specifically tells us othewise through the Python3_EXECUTABLE hint.
# Setting CMP0094 to NEW means that the search will stop after the first
# python version is found.  Setting Python3_FIND_UNVERSIONED_NAMES means that
# the search will prefer /usr/bin/python3 over /usr/bin/python3.11.  And that
# latter functionality is only available in CMake 3.20 or later, so we need
# at least that version.
cmake_minimum_required(VERSION 3.20)
cmake_policy(SET CMP0094 NEW)
set(Python3_FIND_UNVERSIONED_NAMES FIRST)

find_package(Python3 REQUIRED COMPONENTS Interpreter Development)

if(__PYTHON_QT_BINDING_SHIBOKEN_HELPER_INCLUDED)
  return()
endif()
set(__PYTHON_QT_BINDING_SHIBOKEN_HELPER_INCLUDED TRUE)

# In CMake 3.27 and later, FindPythonInterp and FindPythonLibs are deprecated.
# However, Shiboken2 as packaged in Ubuntu 24.04 still use them, so set CMP0148 to
# "OLD" to silence this warning.
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.27.0")
  cmake_policy(SET CMP0148 OLD)
endif()
find_package(Shiboken2 QUIET)
if(Shiboken2_FOUND)
  message(STATUS "Found Shiboken2 version ${Shiboken2_VERSION}")
  if(NOT ${Shiboken2_VERSION} VERSION_LESS "5.13")
    get_property(SHIBOKEN_INCLUDE_DIR TARGET Shiboken2::libshiboken PROPERTY INTERFACE_INCLUDE_DIRECTORIES)
    get_property(SHIBOKEN_LIBRARY TARGET Shiboken2::libshiboken PROPERTY LOCATION)
    set(SHIBOKEN_BINARY Shiboken2::shiboken2)
  endif()
  message(STATUS "Using SHIBOKEN_INCLUDE_DIR: ${SHIBOKEN_INCLUDE_DIR}")
  message(STATUS "Using SHIBOKEN_LIBRARY: ${SHIBOKEN_LIBRARY}")
  message(STATUS "Using SHIBOKEN_BINARY: ${SHIBOKEN_BINARY}")
endif()

find_package(PySide2 QUIET)
if(PySide2_FOUND)
  message(STATUS "Found PySide2 version ${PySide2_VERSION}")
  if(NOT ${PySide2_VERSION} VERSION_LESS "5.13")
    get_property(PYSIDE_INCLUDE_DIR TARGET PySide2::pyside2 PROPERTY INTERFACE_INCLUDE_DIRECTORIES)
    get_property(PYSIDE_LIBRARY TARGET PySide2::pyside2 PROPERTY LOCATION)
  endif()
  message(STATUS "Using PYSIDE_INCLUDE_DIR: ${PYSIDE_INCLUDE_DIR}")
  message(STATUS "Using PYSIDE_LIBRARY: ${PYSIDE_LIBRARY}")
endif()

if(Shiboken2_FOUND AND PySide2_FOUND)
  message(STATUS "Shiboken binding generator available.")
  set(shiboken_helper_FOUND TRUE)
else()
  message(STATUS "Shiboken binding generator NOT available.")
  set(shiboken_helper_NOTFOUND TRUE)
endif()


macro(_shiboken_generator_command VAR GLOBAL TYPESYSTEM INCLUDE_PATH BUILD_DIR)
  # Add includes from current directory, Qt, PySide and compiler specific dirs
  get_directory_property(SHIBOKEN_HELPER_INCLUDE_DIRS INCLUDE_DIRECTORIES)
  list(APPEND SHIBOKEN_HELPER_INCLUDE_DIRS
    ${QT_INCLUDE_DIR}
    ${PYSIDE_INCLUDE_DIR}
    ${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES})
  # See ticket https://code.ros.org/trac/ros-pkg/ticket/5219
  set(SHIBOKEN_HELPER_INCLUDE_DIRS_WITH_COLONS "")
  foreach(dir ${SHIBOKEN_HELPER_INCLUDE_DIRS})
    set(SHIBOKEN_HELPER_INCLUDE_DIRS_WITH_COLONS "${SHIBOKEN_HELPER_INCLUDE_DIRS_WITH_COLONS}:${dir}")
  endforeach()
  string(REPLACE ";" ":" INCLUDE_PATH_WITH_COLONS "${INCLUDE_PATH}")
  set(${VAR} ${SHIBOKEN_BINARY}
    --generatorSet=shiboken
    --enable-pyside-extensions
    -std=c++17
    --include-paths=${INCLUDE_PATH_WITH_COLONS}${SHIBOKEN_HELPER_INCLUDE_DIRS_WITH_COLONS}
    --typesystem-paths=${PYSIDE_TYPESYSTEMS}
    --output-directory=${BUILD_DIR} ${GLOBAL} ${TYPESYSTEM})
endmacro()


#
# Run the Shiboken generator.
#
# :param PROJECT_NAME: The name of the shiboken project is only use for
#   the custom command comment
# :type PROJECT_NAME: string
# :param GLOBAL: the SIP file
# :type GLOBAL: string
# :param TYPESYSTEM: the typesystem file
# :type TYPESYSTEM: string
# :param WORKING_DIR: the working directory
# :type WORKING_DIR: string
# :param GENERATED_SRCS: the generated source files
# :type GENERATED_SRCS: list of strings
# :param HDRS: the processed header files
# :type HDRS: list of strings
# :param INCLUDE_PATH: the include path
# :type INCLUDE_PATH: list of strings
# :param BUILD_DIR: the build directory
# :type BUILD_DIR: string
#
function(shiboken_generator PROJECT_NAME GLOBAL TYPESYSTEM WORKING_DIR GENERATED_SRCS HDRS INCLUDE_PATH BUILD_DIR)
  _shiboken_generator_command(COMMAND "${GLOBAL}" "${TYPESYSTEM}" "${INCLUDE_PATH}" "${BUILD_DIR}")
  add_custom_command(
    OUTPUT ${GENERATED_SRCS}
    COMMAND ${COMMAND}
    DEPENDS ${GLOBAL} ${TYPESYSTEM} ${HDRS}
    WORKING_DIRECTORY ${WORKING_DIR}
    COMMENT "Running Shiboken generator for ${PROJECT_NAME} Python bindings..."
  )
endfunction()


#
# Add the Shiboken/PySide specific include directories.
#
# :param PROJECT_NAME: The namespace of the binding
# :type PROJECT_NAME: string
# :param QT_COMPONENTS: the Qt components
# :type QT_COMPONENTS: list of strings
#
function(shiboken_include_directories PROJECT_NAME QT_COMPONENTS)
  set(shiboken_INCLUDE_DIRECTORIES
    ${Python3_INCLUDE_DIRS}
    ${SHIBOKEN_INCLUDE_DIR}
    ${PYSIDE_INCLUDE_DIR}
    ${PYSIDE_INCLUDE_DIR}/QtCore
    ${PYSIDE_INCLUDE_DIR}/QtGui
  )

  foreach(component ${QT_COMPONENTS})
    set(shiboken_INCLUDE_DIRECTORIES ${shiboken_INCLUDE_DIRECTORIES} ${PYSIDE_INCLUDE_DIR}/${component})
  endforeach()

  include_directories(${PROJECT_NAME} ${shiboken_INCLUDE_DIRECTORIES})
endfunction()


#
# Add the Shiboken/PySide specific link libraries.
#
# :param PROJECT_NAME: The target name of the binding library
# :type PROJECT_NAME: string
# :param QT_COMPONENTS: the Qt components
# :type QT_COMPONENTS: list of strings
#
function(shiboken_target_link_libraries PROJECT_NAME QT_COMPONENTS)
  set(shiboken_LINK_LIBRARIES
    ${SHIBOKEN_PYTHON_LIBRARIES}
    ${SHIBOKEN_LIBRARY}
    ${PYSIDE_LIBRARY}
  )

  foreach(component ${QT_COMPONENTS})
    string(TOUPPER ${component} component)
    set(shiboken_LINK_LIBRARIES ${shiboken_LINK_LIBRARIES} ${QT_${component}_LIBRARY})
  endforeach()

  target_link_libraries(${PROJECT_NAME} ${shiboken_LINK_LIBRARIES})
endfunction()
