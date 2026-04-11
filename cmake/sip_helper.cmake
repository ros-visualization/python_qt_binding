if(__PYTHON_QT_BINDING_SIP_HELPER_INCLUDED)
  return()
endif()
set(__PYTHON_QT_BINDING_SIP_HELPER_INCLUDED TRUE)

set(__PYTHON_QT_BINDING_SIP_HELPER_DIR ${CMAKE_CURRENT_LIST_DIR})

cmake_minimum_required(VERSION 3.20)
cmake_policy(SET CMP0094 NEW)
set(Python3_FIND_UNVERSIONED_NAMES FIRST)

find_package(Python3 ${Python3_VERSION} REQUIRED COMPONENTS Interpreter Development)

# Find the directory containing the SIP bindings shipped by PyQt.
#
# :param python_qt_binding_QT_MAJOR_VERSION: The major version of Qt (e.g., 5 or 6).
#
# :out __PYQT_BINDINGS_DIR: Path to the directory containing QT*.sip files.
# :out __PYQT_BINDINGS_FOUND: Boolean indicating if the bindings were located.
#
function(__find_qt_sip_files python_qt_binding_QT_MAJOR_VERSION)
    set(MODULE_NAME "PyQt${python_qt_binding_QT_MAJOR_VERSION}")

    execute_process(
        COMMAND ${Python3_EXECUTABLE} -c "import ${MODULE_NAME}.bindings as pb; print(pb.__path__[0])"
        OUTPUT_VARIABLE BINDINGS_DIR
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
        RESULT_VARIABLE _res
    )

    if(_res EQUAL 0 AND IS_DIRECTORY "${BINDINGS_DIR}")
        set(__PYQT_BINDINGS_DIR "${BINDINGS_DIR}" PARENT_SCOPE)
        set(__PYQT_BINDINGS_FOUND TRUE PARENT_SCOPE)
        message(STATUS "Found ${MODULE_NAME} SIP bindings at: ${BINDINGS_DIR}")
    else()
        set(__PYQT_BINDINGS_FOUND FALSE PARENT_SCOPE)
        message(WARNING "Could not determine ${MODULE_NAME} bindings directory.")
    endif()
endfunction()

# Extract the sip-abi-version from PyQt's configuration
#
# :param BINDINGS_DIR: Path to the directory containing QT*.sip files.
# :out __QT_SIP_ABI_VERSION: The detected ABI version (defaults to 12).
function(__find_qt_sip_abi BINDINGS_DIR)
    # Default to 12 if detection fails
    set(DETECTED_ABI "12")
    set(TOML_FILE "${BINDINGS_DIR}/QtCore/QtCore.toml")

    if(EXISTS "${TOML_FILE}")
        file(READ "${TOML_FILE}" TOML_CONTENT_STR)
        if(TOML_CONTENT_STR MATCHES "sip-abi-version[ \t]*=[ \t]*\"([^\"]+)\"")
            set(DETECTED_ABI ${CMAKE_MATCH_1})
            message(STATUS "Detected SIP ABI version: ${DETECTED_ABI}")
        endif()
    else()
        message(STATUS "QtCore.toml not found at ${TOML_FILE}, defaulting SIP ABI to 12")
    endif()

    set(__QT_SIP_ABI_VERSION "${DETECTED_ABI}" PARENT_SCOPE)
endfunction()

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

# Find Qt's installed SIP files
__find_qt_sip_files(${python_qt_binding_QT_MAJOR_VERSION})
if(NOT __PYQT_BINDINGS_FOUND)
    message(FATAL_ERROR "PyQt${python_qt_binding_QT_MAJOR_VERSION} SIP bindings are required but were not found.")
endif()

# Extract the sip-abi-version from PyQt
__find_qt_sip_abi("${__PYQT_BINDINGS_DIR}")

# Find qmake
find_program(python_qt_binding_QMAKE_EXECUTABLE
    NAMES
        qmake${python_qt_binding_QT_MAJOR_VERSION}
        qmake-qt${python_qt_binding_QT_MAJOR_VERSION}
        qmake
    REQUIRED)

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

    set(PYPROJECT_TOML "${SIP_BUILD_DIR}/pyproject.toml")
    configure_file(
        "${__PYTHON_QT_BINDING_SIP_HELPER_DIR}/pyproject.toml.in"
        "${PYPROJECT_TOML}"
        @ONLY
    )

    # Find all generated C/C++ files
    set(GENERATED_CPP
        "${SIP_BUILD_DIR}/lib${PROJECT_NAME}/siplib${PROJECT_NAME}part0.cpp"
    )

    # Generate code for a cPython extension using sip-build
    add_custom_command(
        OUTPUT ${GENERATED_CPP}
        COMMAND ${Python3_EXECUTABLE} -m sipbuild.tools.build --no-compile --concatenate 1
        DEPENDS ${SIP_FILE} ${sip_DEPENDS}
        WORKING_DIRECTORY ${SIP_BUILD_DIR}
        COMMENT "Generating C++ code for ${PROJECT_NAME} Python bindings using sip-build..."
    )

    # Build the cPython extension natively using CMake
    python3_add_library(lib${PROJECT_NAME} MODULE ${GENERATED_CPP})

    # Link project dependencies against this target
    target_include_directories(lib${PROJECT_NAME} PRIVATE ${${PROJECT_NAME}_INCLUDE_DIRS} ${SIP_BUILD_DIR})
    target_link_libraries(lib${PROJECT_NAME} PRIVATE ${${PROJECT_NAME}_LIBRARIES} ${sip_DEPENDENCIES})
    target_link_directories(lib${PROJECT_NAME} PRIVATE ${${PROJECT_NAME}_LIBRARY_DIRS})

    if(${PROJECT_NAME}_LDFLAGS_OTHER)
        target_link_options(lib${PROJECT_NAME} PRIVATE ${${PROJECT_NAME}_LDFLAGS_OTHER})
    endif()
endfunction()
