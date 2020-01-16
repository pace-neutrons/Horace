function(install_template_file)
    set(_template_file "${arg1}")
    get_filename_component(_new_file_name "${_template_file}" NAME_WE)
    install(
        FILES ${arg1}
        DESTINATION "${CMAKE_INSTALL_PREFIX}"
        RENAME "${_new_file_name}"
        )
endfunction()

set(TEMPLATE_FILES
    "herbert_on.m.template"
    "worker_v2.m.template"
)
foreach(_template_file ${TEMPLATE_FILES})
    install_template_file("${_template_file}")
endforeach()
