if(__PYTHON_QT_BINDING_SIP_HELPER_INCLUDED)
  return()
endif()
set(__PYTHON_QT_BINDING_SIP_HELPER_INCLUDED TRUE)

set(__PYTHON_QT_BINDING_SIP_HELPER_DIR ${CMAKE_CURRENT_LIST_DIR})

cmake_minimum_required(VERSION 3.20)
cmake_policy(SET CMP0094 NEW)
set(Python3_FIND_UNVERSIONED_NAMES FIRST)

find_package(Python3 ${Python3_VERSION} REQUIRED COMPONENTS Interpreter Development)
find_package(Qt5 REQUIRED COMPONENTS Core)

# Check if modern sipbuild is available via python module
execute_process(
  COMMAND ${Python3_EXECUTABLE} -c "import sipbuild"
  RESULT_VARIABLE _sipbuild_res
  ERROR_QUIET)

if(_sipbuild_res EQUAL 0)
  message(STATUS "Modern SIP binding generator (sip-build) is available.")
  set(sip_helper_FOUND TRUE)
else()
  message(STATUS "Modern SIP binding generator NOT available.")
  set(sip_helper_NOTFOUND TRUE)
endif()

#
# Run the SIP generator and compile the generated code into a library.
#
# .. note:: Creates a target named lib${PROJECT_NAME}
#
# :param PROJECT_NAME: The name of the sip project
# :type PROJECT_NAME: string
# :param SIP_FILE: the SIP file to be processed
# :type SIP_FILE: string
#
# The following options can be used to override the default behavior:
#   SIP_CONFIGURE: (IGNORED) Retained for CMake API compatibility only.
#   SOURCE_DIR: the source dir (default: ${PROJECT_SOURCE_DIR}/src)
#   LIBRARY_DIR: the library dir (default: ${PROJECT_SOURCE_DIR}/src)
#   BINARY_DIR: the binary dir (default: ${PROJECT_BINARY_DIR})
#
# The following keywords arguments can be used to specify:
#   DEPENDS: depends for the custom command (should list all sip and header files)
#   DEPENDENCIES: target dependencies
#
function(build_sip_binding PROJECT_NAME SIP_FILE)
    cmake_parse_arguments(sip "" "SIP_CONFIGURE;SOURCE_DIR;LIBRARY_DIR;BINARY_DIR" "DEPENDS;DEPENDENCIES" ${ARGN})
    if(sip_UNPARSED_ARGUMENTS)
        message(WARNING "build_sip_binding(${PROJECT_NAME}) called with unused arguments: ${sip_UNPARSED_ARGUMENTS}")
    endif()

    if(sip_SIP_CONFIGURE)
        message(WARNING "SIP_CONFIGURE argument is deprecated and ignored. CMake now handles configuration natively.")
    endif()

    # set default values for optional arguments
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

    # Extract the filename from the SIP_FILE path
    get_filename_component(SIP_FILE_NAME ${SIP_FILE} NAME)

    # Generate a pyproject.toml to be given to sip-build
    file(MAKE_DIRECTORY ${SIP_BUILD_DIR})
    set(TOML_CONTENT 
"[build-system]
requires = [\"sip >=6, <7\"]
build-backend = \"sipbuild.api\"

[project]
name = \"${PROJECT_NAME}\"
version = \"1.0.0\"

[tool.sip.project]
sip-files-dir = \"${sip_SOURCE_DIR}\"
sip-include-dirs = [\"/usr/lib/python3/dist-packages/PyQt5/bindings\"]
abi-version = \"12\"

[tool.sip.bindings.${PROJECT_NAME}]
sip-file = \"${SIP_FILE_NAME}\"
")
    file(WRITE ${SIP_BUILD_DIR}/pyproject.toml "${TOML_CONTENT}")

    # Expect sip-build to produce a single output file because of the --concatenate 1 agrument below
    set(GENERATED_CPP ${SIP_BUILD_DIR}/build/lib${PROJECT_NAME}/siplib${PROJECT_NAME}part0.cpp)

    # Generate code for a cPython extension using sip-build
    add_custom_command(
        OUTPUT ${GENERATED_CPP}
        COMMAND ${Python3_EXECUTABLE} -m sipbuild.tools.build --no-compile --concatenate 1 --build-dir build
        DEPENDS ${SIP_FILE} ${sip_DEPENDS}
        WORKING_DIRECTORY ${SIP_BUILD_DIR}
        COMMENT "Generating C++ code for ${PROJECT_NAME} Python bindings using sip-build..."
    )

    # Build the cPython extension natively using CMake
    Python3_add_library(lib${PROJECT_NAME} MODULE ${GENERATED_CPP})

    # Link project dependencies against this target
    message(WARNING "Include dirs: ${${PROJECT_NAME}_INCLUDE_DIRS}" )
    target_include_directories(lib${PROJECT_NAME} PRIVATE ${${PROJECT_NAME}_INCLUDE_DIRS})
    target_link_libraries(lib${PROJECT_NAME} PRIVATE ${${PROJECT_NAME}_LIBRARIES} Qt5::Core)
    target_link_directories(lib${PROJECT_NAME} PRIVATE ${${PROJECT_NAME}_LIBRARY_DIRS})

    if(${PROJECT_NAME}_LDFLAGS_OTHER)
        target_link_options(lib${PROJECT_NAME} PRIVATE ${${PROJECT_NAME}_LDFLAGS_OTHER})
    endif()
endfunction()