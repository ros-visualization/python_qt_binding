find_package(PythonInterp "3.3" REQUIRED)

if(__PYTHON_QT_BINDING_SHIBOKEN_HELPER_INCLUDED)
  return()
endif()
set(__PYTHON_QT_BINDING_SHIBOKEN_HELPER_INCLUDED TRUE)

set(PYTHON_SUFFIX ".cpython-${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}m")
set(PYTHON_EXTENSION_SUFFIX "${PYTHON_SUFFIX}-${CMAKE_CXX_LIBRARY_ARCHITECTURE}")

find_package(python_qt_binding REQUIRED)

macro(pyside_config option output_var)
    if(${ARGC} GREATER 2)
        set(is_list ${ARGV2})
    else()
        set(is_list "")
    endif()

    execute_process(
      COMMAND ${Python3_EXECUTABLE} "${python_qt_binding_DIR}/pyside_config.py"
              ${option}
      OUTPUT_VARIABLE ${output_var}
      OUTPUT_STRIP_TRAILING_WHITESPACE)

    if("${${output_var}}" STREQUAL "")
        message(FATAL_ERROR "Error: Calling pyside_config.py ${option} returned no output.")
    endif()
    if(is_list)
        string(REPLACE " " ";" ${output_var} "${${output_var}}")
    endif()
endmacro()



find_package(Shiboken2 QUIET)
if(Shiboken2_FOUND)
  message(STATUS "Found Shiboken2 version ${Shiboken2_VERSION}")
  if(NOT ${Shiboken2_VERSION} VERSION_LESS "5.13")
    get_property(SHIBOKEN_INCLUDE_DIR TARGET Shiboken2::libshiboken PROPERTY INTERFACE_INCLUDE_DIRECTORIES)
    get_property(SHIBOKEN_LIBRARY TARGET Shiboken2::libshiboken PROPERTY LOCATION)
    set(SHIBOKEN_BINARY Shiboken2::shiboken2)
  endif()
else()
  if(WIN32)
    pyside_config(--shiboken-generator-path shiboken_generator_path)
    pyside_config(--shiboken-generator-include-path shiboken_include_dir 1)
    pyside_config(--shiboken-module-shared-libraries-cmake shiboken_shared_libraries 0)

    set(SHIBOKEN_BINARY "${shiboken_generator_path}/shiboken2${CMAKE_EXECUTABLE_SUFFIX}")
    set(SHIBOKEN_LIBRARY ${shiboken_shared_libraries})
    set(SHIBOKEN_INCLUDE_DIR ${shiboken_include_dir})
  endif()
endif()

message(STATUS "Using SHIBOKEN_INCLUDE_DIR: ${SHIBOKEN_INCLUDE_DIR}")
message(STATUS "Using SHIBOKEN_LIBRARY: ${SHIBOKEN_LIBRARY}")
message(STATUS "Using SHIBOKEN_BINARY: ${SHIBOKEN_BINARY}")

set(PYTHON_BASENAME "${PYTHON_SUFFIX}-${CMAKE_CXX_LIBRARY_ARCHITECTURE}")

find_package(PySide2 QUIET)
if(PySide2_FOUND)
  message(STATUS "Found PySide2 version ${PySide2_VERSION}")
  if(NOT ${PySide2_VERSION} VERSION_LESS "5.13")
    get_property(PYSIDE_INCLUDE_DIR TARGET PySide2::pyside2 PROPERTY INTERFACE_INCLUDE_DIRECTORIES)
    get_property(PYSIDE_LIBRARY TARGET PySide2::pyside2 PROPERTY LOCATION)
  endif()
  message(STATUS "Using PYSIDE_INCLUDE_DIR: ${PYSIDE_INCLUDE_DIR}")
  message(STATUS "Using PYSIDE_LIBRARY: ${PYSIDE_LIBRARY}")
else()
  if(WIN32)
    pyside_config(--pyside-include-path pyside_include_dir 1)
    pyside_config(--pyside-shared-libraries-cmake pyside_shared_libraries 0)
    pyside_config(--pyside-path pyside_dir 1)
    set(PYSIDE_INCLUDE_DIR ${pyside_include_dir})
    set(PYSIDE_LIBRARY ${pyside_shared_libraries})
    set(PYSIDE_TYPESYSTEMS "${pyside_dir}/typesystems")
  endif()
endif()
message(STATUS "Using PYSIDE_INCLUDE_DIR: ${PYSIDE_INCLUDE_DIR}")
message(STATUS "Using PYSIDE_LIBRARY: ${PYSIDE_LIBRARY}")

set(Python_ADDITIONAL_VERSIONS "${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}")
find_package(PythonLibs "${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}")

if(Shiboken2_FOUND AND PySide2_FOUND AND PYTHONLIBS_FOUND)
  if(${CMAKE_VERSION} VERSION_LESS "3.14")
    # the shiboken invocation needs CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES
    # which is broken before CMake 3.14
    # see https://gitlab.kitware.com/cmake/cmake/issues/18394
    message(STATUS "Shiboken binding generator available but CMake version is older than 3.14.")
    set(shiboken_helper_NOTFOUND TRUE)
  else()
    message(STATUS "Shiboken binding generator available.")
    set(shiboken_helper_FOUND TRUE)
  endif()
else()
  message(STATUS "Shiboken binding generator NOT available.")
  set(shiboken_helper_NOTFOUND TRUE)
endif()

if(WIN32)
  set(PATH_SPLITTER "\\\;")
else()
  set(PATH_SPLITTER ":")
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
    set(SHIBOKEN_HELPER_INCLUDE_DIRS_WITH_COLONS "${SHIBOKEN_HELPER_INCLUDE_DIRS_WITH_COLONS}${PATH_SPLITTER}${dir}")
  endforeach()
  string(REPLACE ";" "${PATH_SPLITTER}" INCLUDE_PATH_WITH_COLONS "${INCLUDE_PATH}")
  set(${VAR} ${SHIBOKEN_BINARY}
    --generatorSet=shiboken
    --enable-pyside-extensions
    --include-paths=${INCLUDE_PATH_WITH_COLONS}${SHIBOKEN_HELPER_INCLUDE_DIRS_WITH_COLONS}
    --typesystem-paths=${PYSIDE_TYPESYSTEMS}
    --output-directory=${BUILD_DIR} ${GLOBAL} ${TYPESYSTEM}
    --language-level=c++17)
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

function(shiboken_generator_ext PROJECT_NAME GLOBAL TYPESYSTEM WORKING_DIR GENERATED_SRCS INCLUDE_PATH BUILD_DIR)
    _shiboken_generator_command(COMMAND "${GLOBAL}" "${TYPESYSTEM}" "${INCLUDE_PATH}" "${BUILD_DIR}")
    add_custom_command(
        OUTPUT ${GENERATED_SRCS}
        COMMAND ${COMMAND}
      DEPENDS ${GLOBAL} ${TYPESYSTEM}
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
        ${PYTHON_INCLUDE_DIR}
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
