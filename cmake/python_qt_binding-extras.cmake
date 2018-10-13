@[if DEVELSPACE]@
# location of cmake files in develspace
set(python_qt_binding_EXTRAS_DIR "@(CMAKE_CURRENT_SOURCE_DIR)/cmake")
@[else]@
# location of cmake files in installspace
set(python_qt_binding_EXTRAS_DIR "${python_qt_binding_DIR}")
@[end if]@
