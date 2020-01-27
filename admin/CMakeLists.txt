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
    "default_herbert_path='${CMAKE_SOURCE_DIR}/Herbert/herbert_core';"
    _horace_on_script
    "${_horace_on_template}"
)
file(WRITE "${WORKER_CONFIG_DIR}/horace_on.m" "${_horace_on_script}")

# Copy Herbert's worker template
configure_file("${Herbert_WORKER_TEMPLATE}" "${WORKER_CONFIG_DIR}/worker_v2.m")
