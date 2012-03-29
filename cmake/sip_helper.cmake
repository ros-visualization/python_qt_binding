find_program(SIP_EXECUTABLE sip)

if(NOT SIP_EXECUTABLE_NOTFOUND)
  message("SIP binding generator available.")
  set(sip_helper_FOUND TRUE)
else()
  message(WARNING "SIP binding generator NOT available.")
  set(sip_helper_NOTFOUND TRUE)
endif()

function(build_sip_binding PROJECT_NAME SIP_FILE)
    set(oneValueArgs SIP_CONFIGURE SOURCE_DIR LIBRARY_DIR BINARY_DIR)
    set(multiValueArgs DEPENDS DEPENDENCIES)
    cmake_parse_arguments(sip "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    if(sip_UNPARSED_ARGUMENTS)
        message(WARNING "build_sip_binding(${PROJECT_NAME}) called with unused arguments: ${sip_UNPARSED_ARGUMENTS}")
    endif()

    # set default values for optional arguments
    if(NOT sip_SIP_CONFIGURE)
        # without catkin and CFG_EXTRAS the variable can not be set inside that script
        message(FATAL_ERROR "build_sip_binding(${PROJECT_NAME}) missing argument: SIP_CONFIGURE")
        # in the future set default value to sip_configure.py in this directory
        #set(sip_SIP_CONFIGURE ${python_qt_binding_SOURCE_DIR}/cmake/sip_configure.py)
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

    set(INCLUDE_DIRS ${${PROJECT_NAME}_INCLUDE_DIRS})
    set(LIBRARIES ${${PROJECT_NAME}_LIBRARIES})
    set(LIBRARY_DIRS ${${PROJECT_NAME}_LIBRARY_DIRS})
    set(LDFLAGS_OTHER ${${PROJECT_NAME}_LDFLAGS_OTHER})

    add_custom_command(
        OUTPUT ${SIP_BUILD_DIR}/Makefile
        COMMAND python ${sip_SIP_CONFIGURE} ${SIP_BUILD_DIR} ${SIP_FILE} ${sip_LIBRARY_DIR} \"${INCLUDE_DIRS}\" \"${LIBRARIES}\" \"${LIBRARY_DIRS}\" \"${LDFLAGS_OTHER}\"
        DEPENDS ${sip_SIP_CONFIGURE} ${SIP_FILE} ${sip_DEPENDS}
        WORKING_DIRECTORY ${sip_SOURCE_DIR}
        COMMENT "Running SIP generator for ${PROJECT_NAME} Python bindings..."
    )

    if(NOT EXISTS "${sip_LIBRARY_DIR}")
        file(MAKE_DIRECTORY ${sip_LIBRARY_DIR})
    endif()

    add_custom_command(
        OUTPUT ${sip_LIBRARY_DIR}/lib${PROJECT_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX}
        COMMAND make
        DEPENDS ${SIP_BUILD_DIR}/Makefile
        WORKING_DIRECTORY ${SIP_BUILD_DIR}
        COMMENT "Compiling generated code for ${PROJECT_NAME} Python bindings..."
    )

    add_custom_target(lib${PROJECT_NAME} ALL
        DEPENDS ${sip_LIBRARY_DIR}/lib${PROJECT_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX}
        COMMENT "Meta target for ${PROJECT_NAME} Python bindings..."
    )
    add_dependencies(lib${PROJECT_NAME} ${sip_DEPENDENCIES})
endfunction()
