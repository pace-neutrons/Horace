set(TEST_DIRECTORIES
    "test_admin"
    "test_algorithms"
    "test_ascii_column_data"
    "test_change_crystal"
    "test_combine"
    "test_configuration"
    "test_converters"
    "test_dnd_class"
    "test_gen_sqw_for_powders"
    "test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_herbert"
    "test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_mex"
    "test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_nomex"
    "test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_parpool"
    "test_herbert_utilites"
    "test_mex_nomex"
    "test_multifit"
    "test_rebin"
    "test_sqw_file"
    "test_sqw"
    "test_sqw_class"
    "test_sym_op"
    "test_symmetrisation"
    "test_tobyfit"
    "test_tobyfit/test_let"
    "test_tobyfit/test_refine_crystal"
    "test_transformation"
    "test_utilities"
)
# The MPI tests require that the `[herbert|horace]_on` and `worker_v2`scripts
# be on the path for all workers when Matlab starts up: add the path of the
# directory it's copied into to the MATLABPATH environment variable when tests
# are run.
# LOCAL_INIT_DIR is defined in the top-level CMakeLists
file(TO_CMAKE_PATH "$ENV{MATLABPATH}" MATLAB_PATH)
if(WIN32)
    set(MATLAB_PATH "${MATLAB_PATH}\;${LOCAL_INIT_DIR}")
else()
    set(MATLAB_PATH "${MATLAB_PATH}:${LOCAL_INIT_DIR}")
endif()

set(ENV_VARIABLES
    # paths automatically added to Matlab path
    "MATLABPATH=${MATLAB_PATH}"
    # temporary directory for Matlab - prevents read/write collisions on Jenkins
    "TMP=${CMAKE_BINARY_DIR}/tests"
)

foreach(_test_dir ${TEST_DIRECTORIES})
    if("${_test_dir}" STREQUAL "test_sqw")
        set(TEST_TIMEOUT_LENGTH "1500")  # 25 minutes
    elseif("${_test_dir}" STREQUAL "test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_parpool")
        set(TEST_TIMEOUT_LENGTH "2100")  # 35 minutes
    elseif("${_test_dir}" STREQUAL "test_tobyfit")
        set(TEST_TIMEOUT_LENGTH "3000")  # 50 minutes
    elseif("${_test_dir}" STREQUAL "test_gen_sqw_workflow")
        set(TEST_TIMEOUT_LENGTH "3000")  # 50 minutes
    else()
        set(TEST_TIMEOUT_LENGTH "960")  # 16 minutes
    endif()

    set(TEST_NAME "Matlab.${_test_dir}")
    matlab_add_unit_test(
        NAME "${TEST_NAME}"
        CUSTOM_TEST_COMMAND
            "validate_horace ${_test_dir} -talkative -forcemex -exit_on_completion"
        ADDITIONAL_PATH "${Horace_ROOT}/admin"
        TIMEOUT ${TEST_TIMEOUT_LENGTH}
    )
    set_tests_properties("${TEST_NAME}"
        PROPERTIES
            ENVIRONMENT "${ENV_VARIABLES}"
    )
endforeach()
