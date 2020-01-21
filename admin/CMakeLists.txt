# Copy template files into <build_dir>/herbert_config
set(WORKER_CONFIG_DIR "${CMAKE_BINARY_DIR}/herbert_config")
file(MAKE_DIRECTORY ${WORKER_CONFIG_DIR})
if(${BUILD_TESTS})
    configure_file("worker_4tests.m.template" "${WORKER_CONFIG_DIR}/worker_4tests.m")
endif()
configure_file("worker_v2.m.template" "${WORKER_CONFIG_DIR}/worker_v2.m")

file(READ "herbert_on.m.template" _herbert_on_template)
string(REPLACE
    "her_default_path='/usr/local/mprogs/Herbert'"
    "her_default_path='${CMAKE_SOURCE_DIR}/herbert_core'"
    _herbert_on_script
    "${_herbert_on_template}"
)
file(WRITE "${WORKER_CONFIG_DIR}/herbert_on.m" "${_herbert_on_script}")

# =============================================================================
# Install commands
# =============================================================================
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
