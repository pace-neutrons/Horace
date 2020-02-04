# Copy template files into <build_dir>/local_init
# LOCAL_INIT_DIR is defined in the top-level CMakeLists
file(MAKE_DIRECTORY ${LOCAL_INIT_DIR})

# Regex to match a standard Unix/Windwows path - especially the default paths
# in herbert_on.m.template and horace_on.m.template
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
file(WRITE "${LOCAL_INIT_DIR}/horace_on.m" "${_horace_on_script}")

# Format and copy herbert_on template
file(READ "${Herbert_ON_TEMPLATE}" _herbert_on_template)
string(REGEX REPLACE
    "default_herbert_path ?= ?'${_path_regex}';"
    "default_herbert_path = '${Herbert_ROOT}';"
    _herbert_on_script
    "${_herbert_on_template}"
)
file(WRITE "${LOCAL_INIT_DIR}/herbert_on.m" "${_herbert_on_script}")

# Copy Herbert's worker template
configure_file("${Herbert_WORKER_TEMPLATE}" "${LOCAL_INIT_DIR}/worker_v2.m")

# =============================================================================
# Install commands
# =============================================================================
# Function to install a file whose name ends in .template
function(install_template_file)
    set(_template_file "${ARGV0}")
    get_filename_component(_template_base_name "${_template_file}" NAME)
    string(REPLACE ".template" "" _new_file_name "${_template_base_name}")
    install(
        FILES "${_template_file}"
        DESTINATION "."
        RENAME "${_new_file_name}"
    )
endfunction()

set(TEMPLATE_FILES
    "horace_on.m.template"
    "${Herbert_ON_TEMPLATE}"
    "${Herbert_WORKER_TEMPLATE}"
)
foreach(_template_file ${TEMPLATE_FILES})
    install_template_file("${_template_file}")
endforeach()
