find_program(SIP_EXECUTABLE sip)

if(NOT SIP_EXECUTABLE_NOTFOUND)
  message("SIP binding generator available.")
  set(sip_helper_FOUND TRUE)
else()
  message(WARNING "SIP binding generator NOT available.")
  set(sip_helper_NOTFOUND TRUE)
endif()

function(build_sip_binding PROJECT_NAME SIP_CONFIGURE SIP_FILE DEPENDED_SIPS HDRS SOURCE_DIR LIBRARY_DIR BINARY_DIR)
    set(SIP_BUILD_DIR ${BINARY_DIR}/sip/${PROJECT_NAME})

    set(INCLUDE_DIRS ${${PROJECT_NAME}_INCLUDE_DIRS})
    set(LIBRARIES ${${PROJECT_NAME}_LIBRARIES})
    set(LIBRARY_DIRS ${${PROJECT_NAME}_LIBRARY_DIRS})
    set(LDFLAGS_OTHER ${${PROJECT_NAME}_LDFLAGS_OTHER})

    add_custom_command(
        OUTPUT ${SIP_BUILD_DIR}/Makefile
        COMMAND python ${SIP_CONFIGURE} ${SIP_BUILD_DIR} ${SIP_FILE} ${LIBRARY_DIR} \"${INCLUDE_DIRS}\" \"${LIBRARIES}\" \"${LIBRARY_DIRS}\" \"${LDFLAGS_OTHER}\"
        DEPENDS ${SIP_CONFIGURE} ${DEPENDED_SIPS} ${HDRS}
        WORKING_DIRECTORY ${SOURCE_DIR}
        COMMENT "Running SIP generator for ${PROJECT_NAME} Python bindings..."
    )

    if(NOT EXISTS "${LIBRARY_DIR}")
        file(MAKE_DIRECTORY ${LIBRARY_DIR})
    endif()

    add_custom_target(lib${PROJECT_NAME}.so ALL
        COMMAND make
        DEPENDS ${SIP_BUILD_DIR}/Makefile
        WORKING_DIRECTORY ${SIP_BUILD_DIR}
        COMMENT "Compiling generated code for ${PROJECT_NAME} Python bindings..."
    )
endfunction()
