if(__PYTHON_QT_BINDING_SIP_HELPER_INCLUDED)
  return()
endif()
set(__PYTHON_QT_BINDING_SIP_HELPER_INCLUDED TRUE)

set(__PYTHON_QT_BINDING_SIP_HELPER_DIR ${CMAKE_CURRENT_LIST_DIR})

set(Python_ADDITIONAL_VERSIONS "${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}")
find_package(PythonInterp "${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}" REQUIRED)
assert(PYTHON_EXECUTABLE)
find_package(PythonLibs "${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}" REQUIRED)

execute_process(
  COMMAND ${PYTHON_EXECUTABLE} -c "import sipconfig; print(sipconfig.Configuration().sip_bin)"
  OUTPUT_VARIABLE PYTHON_SIP_EXECUTABLE
  ERROR_QUIET)

if(PYTHON_SIP_EXECUTABLE)
  string(STRIP ${PYTHON_SIP_EXECUTABLE} SIP_EXECUTABLE)
else()
  find_program(SIP_EXECUTABLE NAMES sip sip-build)
endif()

if(SIP_EXECUTABLE)
  message(STATUS "SIP binding generator available at: ${SIP_EXECUTABLE}")
  set(sip_helper_FOUND TRUE)
else()
  message(WARNING "SIP binding generator NOT available.")
  set(sip_helper_NOTFOUND TRUE)
endif()

if(sip_helper_FOUND)
  execute_process(
    COMMAND ${SIP_EXECUTABLE} -V
    OUTPUT_VARIABLE SIP_VERSION
    ERROR_QUIET)
  string(STRIP ${SIP_VERSION} SIP_VERSION)
  message(STATUS "SIP binding generator version: ${SIP_VERSION}")
endif()

#
# Run the SIP generator and compile the generated code into a library.
#
# .. note:: The target lib${PROJECT_NAME} is created.
#
# :param PROJECT_NAME: The name of the sip project
# :type PROJECT_NAME: string
# :param SIP_FILE: the SIP file to be processed
# :type SIP_FILE: string
#
# The following options can be used to override the default behavior:
#   SIP_CONFIGURE: the used configure script for SIP
#     (default: sip_configure.py in the same folder as this file)
#   SOURCE_DIR: the source dir (default: ${PROJECT_SOURCE_DIR}/src)
#   LIBRARY_DIR: the library dir (default: ${PROJECT_SOURCE_DIR}/src)
#   BINARY_DIR: the binary dir (default: ${PROJECT_BINARY_DIR})
#
# The following keywords arguments can be used to specify:
#   DEPENDS: depends for the custom command
#     (should list all sip and header files)
#   DEPENDENCIES: target dependencies
#     (should list the library for which SIP generates the bindings)
#
function(build_sip_binding PROJECT_NAME SIP_FILE)
    cmake_parse_arguments(sip "" "SIP_CONFIGURE;SOURCE_DIR;LIBRARY_DIR;BINARY_DIR" "DEPENDS;DEPENDENCIES" ${ARGN})
    if(sip_UNPARSED_ARGUMENTS)
        message(WARNING "build_sip_binding(${PROJECT_NAME}) called with unused arguments: ${sip_UNPARSED_ARGUMENTS}")
    endif()

    # set default values for optional arguments
    if(NOT sip_SIP_CONFIGURE)
        # default to sip_configure.py in this directory
        set(sip_SIP_CONFIGURE ${__PYTHON_QT_BINDING_SIP_HELPER_DIR}/sip_configure.py)
    endif()
    if(NOT sip_SOURCE_DIR)
        set(sip_SOURCE_DIR ${PROJECT_SOURCE_DIR}/src)
    endif()
    if(NOT sip_LIBRARY_DIR)
        set(sip_LIBRARY_DIR ${PROJECT_SOURCE_DIR}/lib)
    endif()
    if(NOT sip_BINARY_DIR)
        set(sip_BINARY_DIR ${PROJECT_BINARY_DIR})
    endif()

    set(SIP_BUILD_DIR ${sip_BINARY_DIR}/sip/${PROJECT_NAME})

    set(INCLUDE_DIRS ${${PROJECT_NAME}_INCLUDE_DIRS} ${PYTHON_INCLUDE_DIRS})
    set(LIBRARY_DIRS ${${PROJECT_NAME}_LIBRARY_DIRS})
    set(LDFLAGS_OTHER ${${PROJECT_NAME}_LDFLAGS_OTHER})

    set(EXTRA_DEFINES "")
    if(DEFINED BUILD_SHARED_LIBS AND BUILD_SHARED_LIBS)
      set(EXTRA_DEFINES "ROS_BUILD_SHARED_LIBS")
    endif()

    # SIP configure doesn't handle build configuration keywords
    catkin_filter_libraries_for_build_configuration(LIBRARIES ${${PROJECT_NAME}_LIBRARIES})
    # SIP configure doesn't handle CMake targets
    catkin_replace_imported_library_targets(LIBRARIES ${LIBRARIES})

    if(${SIP_VERSION} VERSION_GREATER_EQUAL "5.0.0")
        # Since v5, SIP implements the backend per PEP 517, PEP 518
        # Here we synthesize `pyproject.toml` and run `pip install`

        find_program(QMAKE_EXECUTABLE NAMES qmake REQUIRED)

        file(REMOVE_RECURSE ${SIP_BUILD_DIR})
        file(MAKE_DIRECTORY ${sip_LIBRARY_DIR})

        set(SIP_FILES_DIR ${sip_SOURCE_DIR})

        set(SIP_INCLUDE_DIRS "")
        foreach(_x ${INCLUDE_DIRS})
          set(SIP_INCLUDE_DIRS "${SIP_INCLUDE_DIRS},\"${_x}\"")
        endforeach()
        string(REGEX REPLACE "^," "" SIP_INCLUDE_DIRS ${SIP_INCLUDE_DIRS})

        # SIP expects the libraries WITHOUT the file extension.
        set(SIP_LIBARIES "")
        foreach(_x ${LIBRARIES} ${PYTHON_LIBRARIES})
          get_filename_component(_x_NAME "${_x}" NAME_WLE)
          get_filename_component(_x_DIR "${_x}" DIRECTORY)
          get_filename_component(_x "${_x_DIR}/${_x_NAME}" ABSOLUTE)
          set(SIP_LIBARIES "${SIP_LIBARIES},\"${_x}\"")
        endforeach()
        string(REGEX REPLACE "^," "" SIP_LIBARIES ${SIP_LIBARIES})

        set(SIP_LIBRARY_DIRS "")
        foreach(_x ${LIBRARY_DIRS})
          set(SIP_LIBRARY_DIRS "${SIP_LIBRARY_DIRS},\"${_x}\"")
        endforeach()
        string(REGEX REPLACE "^," "" SIP_LIBRARY_DIRS ${SIP_LIBRARY_DIRS})

        set(SIP_EXTRA_DEFINES "")
        foreach(_x ${EXTRA_DEFINES})
          set(SIP_EXTRA_DEFINES "${SIP_EXTRA_DEFINES},\"${_x}\"")
        endforeach()
        string(REGEX REPLACE "^," "" SIP_EXTRA_DEFINES ${SIP_EXTRA_DEFINES})

        # TODO:
        #   I don't know what to do about LDFLAGS_OTHER
        #   what's the equivalent construct in sip5?

        configure_file(
            ${__PYTHON_QT_BINDING_SIP_HELPER_DIR}/pyproject.toml.in
            ${sip_BINARY_DIR}/sip/pyproject.toml
        )
        add_custom_command(
            OUTPUT ${sip_LIBRARY_DIR}/lib${PROJECT_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX}
            COMMAND ${PYTHON_EXECUTABLE} -m pip install . --target ${sip_LIBRARY_DIR} --no-deps
            DEPENDS ${sip_SIP_CONFIGURE} ${SIP_FILE} ${sip_DEPENDS}
            WORKING_DIRECTORY ${sip_BINARY_DIR}/sip
            COMMENT "Running SIP-build generator for ${PROJECT_NAME} Python bindings..."
        )
    else()
        add_custom_command(
            OUTPUT ${SIP_BUILD_DIR}/Makefile
            COMMAND ${PYTHON_EXECUTABLE} ${sip_SIP_CONFIGURE} ${SIP_BUILD_DIR} ${SIP_FILE} ${sip_LIBRARY_DIR} \"${INCLUDE_DIRS}\" \"${LIBRARIES}\" \"${LIBRARY_DIRS}\" \"${LDFLAGS_OTHER}\" \"${EXTRA_DEFINES}\"
            DEPENDS ${sip_SIP_CONFIGURE} ${SIP_FILE} ${sip_DEPENDS}
            WORKING_DIRECTORY ${sip_SOURCE_DIR}
            COMMENT "Running SIP generator for ${PROJECT_NAME} Python bindings..."
        )

        if(NOT EXISTS "${sip_LIBRARY_DIR}")
            file(MAKE_DIRECTORY ${sip_LIBRARY_DIR})
        endif()

        if(WIN32)
          set(MAKE_EXECUTABLE NMake.exe)
        else()
          set(MAKE_EXECUTABLE "\$(MAKE)")
        endif()

        add_custom_command(
            OUTPUT ${sip_LIBRARY_DIR}/lib${PROJECT_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX}
            COMMAND ${MAKE_EXECUTABLE}
            DEPENDS ${SIP_BUILD_DIR}/Makefile
            WORKING_DIRECTORY ${SIP_BUILD_DIR}
            COMMENT "Compiling generated code for ${PROJECT_NAME} Python bindings..."
        )
    endif()

    add_custom_target(lib${PROJECT_NAME} ALL
        DEPENDS ${sip_LIBRARY_DIR}/lib${PROJECT_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX}
        COMMENT "Meta target for ${PROJECT_NAME} Python bindings..."
    )
    add_dependencies(lib${PROJECT_NAME} ${sip_DEPENDENCIES})
endfunction()
