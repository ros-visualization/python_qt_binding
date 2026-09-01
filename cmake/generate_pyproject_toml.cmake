# Called via cmake -P from build_sip_binding() in sip_helper.cmake.
# Performs @VAR@ substitution on pyproject.toml.in and writes the result.
#
# Required variables (passed via -DVAR=value on the cmake command line):
#   PROJECT_NAME
#   python_qt_binding_QMAKE_EXECUTABLE
#   SIP_BUILD_DIR
#   sip_SOURCE_DIR
#   SIP_FILE_NAME
#   __PYQT_BINDINGS_DIR
#   __QT_SIP_ABI_VERSION
#   TEMPLATE_FILE
#   OUTPUT_FILE
configure_file("${TEMPLATE_FILE}" "${OUTPUT_FILE}" @ONLY)
