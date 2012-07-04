# - Check if shiboken supports a QGenericReturnArgument with empty constructor
# shiboken_check_qgenericreturnargument(<var>)
#  <var> - variable to store whether shiboken support QGenericReturnArgument

find_package(Qt4 REQUIRED COMPONENTS QtCore)
include(${QT_USE_FILE})

include(shiboken_check_compiles)

macro(shiboken_check_qgenericreturnargument SHIBOKEN_QGENERICRETURNARGUMENT_SUPPORT)
  set(SOURCE_HEADER "#include <QGenericReturnArgument>
    void func(QGenericReturnArgument arg);
  ")
  set(GLOBAL_HEADER "#include \"pyside_global.h\"
    #include <QtCore/QtCore>
  ")
  set(TYPESYSTEM_XML "<?xml version=\"1.0\"?>
    <typesystem package=\"libtest\">
      <load-typesystem name=\"typesystem_core.xml\" generate=\"no\"/>
      <function signature=\"func(QGenericReturnArgument)\"/>
    </typesystem>
  ")

  shiboken_check_compiles(${SHIBOKEN_QGENERICRETURNARGUMENT_SUPPORT} "${SOURCE_HEADER}" "${GLOBAL_HEADER}" "${TYPESYSTEM_XML}")
endmacro()
