# - Check if given source can be processed with shiboken
# shiboken_check_compiles(<var> <source_header> <global_header> <typesystem_xml>)
#  <var>            - variable to store whether the source code compiled
#  <source_header>  - source code to try to compile
#  <global_header>  - source code of global.h, the inldue for the file containing source_header is appended internally
#  <typesystem_xml> - typesystem xml

include(${python_qt_binding_EXTRAS_DIR}/shiboken_helper.cmake)

macro(shiboken_check_compiles VAR SOURCE_HEADER GLOBAL_HEADER TYPESYSTEM_XML)
    set(_PATH "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/shiboken_check_compiles")
    set(SOURCE_HEADER "${SOURCE_HEADER}\n")
    set(GLOBAL_HEADER "${GLOBAL_HEADER}\n#include <source.h>\n")

    file(WRITE "${_PATH}/source.h" "${SOURCE_HEADER}")
    file(WRITE "${_PATH}/global.h" "${GLOBAL_HEADER}
        #include \"source.h\"")
    file(WRITE "${_PATH}/typesystem.xml" "${TYPESYSTEM_XML}")

    message(STATUS "Performing Test ${VAR}")
    _shiboken_generator_command(COMMAND global.h typesystem.xml "${_PATH}" "${_PATH}/build")
    execute_process(
        COMMAND ${COMMAND}
        WORKING_DIRECTORY ${_PATH}
        RESULT_VARIABLE ${VAR}
        OUTPUT_VARIABLE _OUTPUT_VARIABLE
        ERROR_VARIABLE _ERROR_VARIABLE
    )

    if(${${VAR}} STREQUAL "0")
        message(STATUS "Performing Test ${VAR} - Success")
        set(${VAR} 1 CACHE INTERNAL "Test ${VAR}")
        set(_LOGFILE ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log)
        set(_STATUS "succeeded")
    else()
        message(STATUS "Performing Test ${VAR} - Failed")
        set(${VAR} "" CACHE INTERNAL "Test ${VAR}")
        set(_LOGFILE ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log)
        set(_STATUS "failed")
    endif()
    file(APPEND ${_LOGFILE}
        "Performing Shiboken COMPILE Test ${VAR} ${_STATUS} with the following output:\n"
        "${_OUTPUT_VARIABLE}\n"
        "Error output was:\n${_ERROR_VARIABLE}\n"
        "Source file was:\n${SOURCE_HEADER}\n"
        "Global header was:\n${GLOBAL_HEADER}\n"
        "Typesystem was:\n${TYPESYSTEM_XML}\n"
    )
endmacro()
