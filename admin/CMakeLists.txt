# Copy template files into <build_dir>/horace_config
set(WORKER_CONFIG_DIR "${CMAKE_BINARY_DIR}/horace_config")
file(MAKE_DIRECTORY ${WORKER_CONFIG_DIR})

# This regex is designed to match a standard Unix/Windows path that may be
# defined as the default path for Herbert/Horace
set(_path_regex "[a-zA-Z0-9/\\\\_\\-\\.: ]+")

# Format and copy horace_on template
file(READ "horace_on.m.template" _horace_on_template)
string(REGEX REPLACE
    "default_horace_path ?= ?'${_path_regex}';"
    "default_horace_path = '${CMAKE_SOURCE_DIR}/horace_core';"
    _horace_on_script
    "${_horace_on_template}"
)
string(REGEX REPLACE
    "default_herbert_path ?= ?'${_path_regex}';"
    "default_herbert_path = '${Herbert_ROOT}';"
    _horace_on_script
    "${_horace_on_script}"
)
file(WRITE "${WORKER_CONFIG_DIR}/horace_on.m" "${_horace_on_script}")

# Format and copy herbert_on template
file(READ "${Herbert_ON_TEMPLATE}" _herbert_on_template)
string(REGEX REPLACE
    "her_default_path ?= ?'${_path_regex}';"
    "her_default_path = '${Herbert_ROOT}';"
    _herbert_on_script
    "${_herbert_on_template}"
)
file(WRITE "${WORKER_CONFIG_DIR}/herbert_on.m" "${_herbert_on_script}")

# Copy Herbert's worker template
configure_file("${Herbert_WORKER_TEMPLATE}" "${WORKER_CONFIG_DIR}/worker_v2.m")
