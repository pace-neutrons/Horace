# Function to install a file whose name ends in .template
function(install_template_file)
    set(_template_file "${ARGV0}")
    string(REPLACE ".template" "" _new_file_name "${_template_file}")
    install(
        FILES "${_template_file}"
        DESTINATION "."
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
