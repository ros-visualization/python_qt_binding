# Avoid find_package(QT NAMES Qt6 Qt5 ...) due to CMake's default ascending path resolution
find_package(Qt6 QUIET COMPONENTS Widgets Core)
if(Qt6_FOUND)
  set(QT_VERSION_MAJOR 6)
else()
  find_package(Qt5 REQUIRED COMPONENTS Widgets Core)
  set(QT_VERSION_MAJOR 5)
endif()
set(python_qt_binding_QT_MAJOR_VERSION "${QT_VERSION_MAJOR}" CACHE STRING "The major version of Qt to use (5 or 6)")
