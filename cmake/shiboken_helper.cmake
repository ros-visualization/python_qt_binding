find_package(GeneratorRunner)
find_package(Shiboken)
find_package(PySide)
find_package(PythonLibs)

if(GeneratorRunner_FOUND AND Shiboken_FOUND AND PySide_FOUND AND PYTHONLIBS_FOUND)
  message("Shiboken binding generator available.")
  set(shiboken_helper_FOUND TRUE)
else()
  message(WARNING "Shiboken binding generator NOT available.")
  set(shiboken_helper_NOTFOUND TRUE)
endif()


function(shiboken_generator PROJECT_NAME GLOBAL TYPESYSTEM WORKING_DIR GENERATED_SRCS HDRS INCLUDE_PATH BUILD_DIR)
    # See ticket https://code.ros.org/trac/ros-pkg/ticket/5219
    set(QT_INCLUDE_DIR_WITH_COLONS "")
    foreach(dir ${QT_INCLUDE_DIR})
        set(QT_INCLUDE_DIR_WITH_COLONS "${QT_INCLUDE_DIR_WITH_COLONS}:${dir}")
    endforeach()

    add_custom_command(
        OUTPUT ${GENERATED_SRCS}
        COMMAND ${GENERATORRUNNER_BINARY}
            --generatorSet=shiboken
            --include-paths=${INCLUDE_PATH}:${QT_INCLUDE_DIR_WITH_COLONS}
            --typesystem-paths=${PYSIDE_TYPESYSTEMS}
            --output-directory=${BUILD_DIR}
        ${GLOBAL}
        ${TYPESYSTEM}
      DEPENDS ${GLOBAL} ${TYPESYSTEM} ${HDRS}
      WORKING_DIRECTORY ${WORKING_DIR}
      COMMENT "Running Shiboken generator for ${PROJECT_NAME} Python bindings..."
    )
endfunction()


function(shiboken_include_directories PROJECT_NAME QT_COMPONENTS)
    set(shiboken_INCLUDE_DIRECTORIES
        ${PYTHON_INCLUDE_DIR}
        ${SHIBOKEN_INCLUDE_DIR}
        ${PYSIDE_INCLUDE_DIR}
        ${PYSIDE_INCLUDE_DIR}/QtCore
        ${PYSIDE_INCLUDE_DIR}/QtGui
    )

    foreach(component ${QT_COMPONENTS})
        set(shiboken_INCLUDE_DIRECTORIES ${shiboken_INCLUDE_DIRECTORIES} ${PYSIDE_INCLUDE_DIR}/${component})
    endforeach()

    include_directories(${PROJECT_NAME} ${shiboken_INCLUDE_DIRECTORIES})
endfunction()


function(shiboken_target_link_libraries PROJECT_NAME QT_COMPONENTS)
    set(shiboken_LINK_LIBRARIES
        ${SHIBOKEN_PYTHON_LIBRARIES}
        ${SHIBOKEN_LIBRARY}
        ${PYSIDE_LIBRARY}
    )
 
    foreach(component ${QT_COMPONENTS})
        string(TOUPPER ${component} component)
        set(shiboken_LINK_LIBRARIES ${shiboken_LINK_LIBRARIES} ${QT_${component}_LIBRARY})
    endforeach()

    target_link_libraries(${PROJECT_NAME} ${shiboken_LINK_LIBRARIES})
endfunction()
