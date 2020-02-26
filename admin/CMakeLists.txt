# Copy template files into <build_dir>/local_init
set(WORKER_CONFIG_DIR "${CMAKE_BINARY_DIR}/local_init")
file(MAKE_DIRECTORY ${WORKER_CONFIG_DIR})
if(${BUILD_TESTS})
    configure_file("worker_4tests.m.template" "${WORKER_CONFIG_DIR}/worker_4tests.m")
endif()
configure_file("worker_v2.m.template" "${WORKER_CONFIG_DIR}/worker_v2.m")

set(_path_regex "[a-zA-Z0-9/\\\\_\\-\\.: ]+")

file(READ "herbert_on.m.template" _herbert_on_template)
string(REGEX REPLACE
    "her_default_path='${_path_regex}'"
    "her_default_path='${CMAKE_SOURCE_DIR}/herbert_core'"
    _herbert_on_script
    "${_herbert_on_template}"
)
file(WRITE "${WORKER_CONFIG_DIR}/herbert_on.m" "${_herbert_on_script}")

# =============================================================================
# Install commands
# =============================================================================
install(
    FILES
        "herbert_on.m.template"
        "herbert_root.m"  # required by validate_herbert
        "validate_herbert.m"
        "worker_4tests.m.template"
        "worker_v2.m.template"
    DESTINATION "Herbert/admin/"
)
