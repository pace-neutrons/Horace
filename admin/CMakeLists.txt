# Copy template files into <build_dir>/horace_config
set(WORKER_CONFIG_DIR "${CMAKE_BINARY_DIR}/horace_config")
file(MAKE_DIRECTORY ${WORKER_CONFIG_DIR})

# Format and copy horace_on template
file(READ "horace_on.m.template" _horace_on_template)
string(REPLACE
    "default_horace_path ='/usr/local/mprogs/Horace/horace_core';"
    "default_horace_path ='${CMAKE_SOURCE_DIR}/horace_core';"
    _horace_on_script
    "${_horace_on_template}"
)
string(REPLACE
    "default_herbert_path='/usr/local/mprogs/Herbert/herbert_core';"
    "default_herbert_path='${Herbert_ROOT}';"
    _horace_on_script
    "${_horace_on_script}"
)
file(WRITE "${WORKER_CONFIG_DIR}/horace_on.m" "${_horace_on_script}")

# Format and copy herbert_on template
file(READ "${Herbert_ON_TEMPLATE}" _herbert_on_template)
string(REPLACE
    "her_default_path='/usr/local/mprogs/Herbert';"
    "her_default_path='${Herbert_ROOT}';"
    _herbert_on_script
    "${_herbert_on_template}"
)
file(WRITE "${WORKER_CONFIG_DIR}/herbert_on.m" "${_herbert_on_script}")

# Copy Herbert's worker template
configure_file("${Herbert_WORKER_TEMPLATE}" "${WORKER_CONFIG_DIR}/worker_v2.m")
