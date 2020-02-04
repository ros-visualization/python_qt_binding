if(__PYTHON_QT_BINDING_SHIBOKEN_HELPER_INCLUDED)
  return()
endif()
set(__PYTHON_QT_BINDING_SHIBOKEN_HELPER_INCLUDED TRUE)

if("${PYTHON_VERSION_MAJOR}" STREQUAL "2")
  set(PYTHON_SUFFIX "-python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}")
elseif("${PYTHON_VERSION_MAJOR}" STREQUAL "3")
  if("${PYTHON_VERSION_MINOR}" STRLESS "3")
    set(PYTHON_SUFFIX ".cpython-${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}mu")
  else()
    set(PYTHON_SUFFIX ".cpython-${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}m")
  endif()
else()
  message(FATAL_ERROR "Unknown Python version: ${PYTHON_VERSION_STRING}")
endif()
set(PYTHON_EXTENSION_SUFFIX "${PYTHON_SUFFIX}-${CMAKE_CXX_LIBRARY_ARCHITECTURE}")

find_package(Shiboken2)
if(${Shiboken2_FOUND})
  if(NOT ${Shiboken2_VERSION} VERSION_LESS "5.13")
    get_property(SHIBOKEN_LIBRARY TARGET Shiboken2::libshiboken PROPERTY LOCATION)
    get_property(SHIBOKEN_INCLUDE_DIR TARGET Shiboken2::libshiboken PROPERTY INTERFACE_INCLUDE_DIRECTORIES)
    SET(SHIBOKEN_BINARY Shiboken2::shiboken2)
  endif()
  message(STATUS "Found Shiboken2 version ${Shiboken2_VERSION}")
  message(STATUS "Using SHIBOKEN_LIBRARY: ${SHIBOKEN_LIBRARY}")
  message(STATUS "Using SHIBOKEN_INCLUDE_DIR: ${SHIBOKEN_INCLUDE_DIR}")
  message(STATUS "Using SHIBOKEN_BINARY: ${SHIBOKEN_BINARY}")
endif()

set(PYTHON_BASENAME "${PYTHON_SUFFIX}-${CMAKE_CXX_LIBRARY_ARCHITECTURE}")

find_package(PySide2)
if(${PySide2_FOUND})
  if(NOT ${PySide2_VERSION} VERSION_LESS "5.13")
    get_property(PYSIDE_LIBRARY TARGET PySide2::pyside2 PROPERTY LOCATION)
    get_property(PYSIDE_INCLUDE_DIR TARGET PySide2::pyside2 PROPERTY INTERFACE_INCLUDE_DIRECTORIES)
  endif()
  message(STATUS "Found PySide2 version ${PySide2_VERSION}")
  message(STATUS "Using PYSIDE_LIBRARY: ${PYSIDE_LIBRARY}")
  message(STATUS "Using PYSIDE_INCLUDE_DIR: ${PYSIDE_INCLUDE_DIR}")
endif()

set(Python_ADDITIONAL_VERSIONS "${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}")
find_package(PythonLibs "${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}")

if(Shiboken2_FOUND AND PySide2_FOUND AND PYTHONLIBS_FOUND)
  message(STATUS "Shiboken binding generator available.")
  set(shiboken_helper_FOUND TRUE)
else()
  message(WARNING "Shiboken binding generator NOT available.")
  set(shiboken_helper_NOTFOUND TRUE)
endif()


macro(_shiboken_generator_command VAR GLOBAL TYPESYSTEM INCLUDE_PATH BUILD_DIR)
    # See ticket https://code.ros.org/trac/ros-pkg/ticket/5219
    set(QT_INCLUDE_DIR_WITH_COLONS "")
    foreach(dir ${QT_INCLUDE_DIR})
        set(QT_INCLUDE_DIR_WITH_COLONS "${QT_INCLUDE_DIR_WITH_COLONS}:${dir}")
    endforeach()
    set(${VAR} ${SHIBOKEN_BINARY} --generatorSet=shiboken --include-paths=${INCLUDE_PATH}${QT_INCLUDE_DIR_WITH_COLONS} --typesystem-paths=${PYSIDE_TYPESYSTEMS} --output-directory=${BUILD_DIR} ${GLOBAL} ${TYPESYSTEM})
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
