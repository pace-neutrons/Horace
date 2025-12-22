# ========================================================================
# ========================================================================
# ===                                                                  ===
# ===  Test directories should appear in one of:                       ===
# ===   - HERBERT_TESTS         (Herbert code unit tests)              ===
# ===   - HERBERT_SYSTEM_TESTS  (Herbert code system tests)            ===
# ===   - HORACE_TESTS          (Horace code unit tests)               ===
# ===   - HORACE_SYSTEM_TESTS   (Horace code system tests)             ===
# ===                                                                  ===
# ===  These CMake variables are read from this file by                ===
# ===  validate_horace.m and enable options of validate_horace to      ===
# ===  select just the Horace or the Herbert tests, or all tests;      ===
# ===  and whether or not to include the system tests                  ===
# ===                                                                  ===
# ===  A given test should only appear in one of the variables.        ===
# ===  Later filtering of tests on the basis of being herbert,         ===
# ===  horace or system tests may otherwise result in unexpected       ===
# ===  tests being run.                                                ===
# ===                                                                  ===
# ===  Do not put tests in any other variables, because otherwise      ===
# ===  validate_horace will not run them.                              ===
# ===                                                                  ===
# ========================================================================
# ========================================================================

set(HERBERT_TESTS
    "test_admin"
    "test_config"
    "test_data_loaders"
    "test_debug_and_test_tools"
    "test_docify"
    "test_instrument_classes"
    "test_IX_classes"
    "test_map_mask"
    "test_mpi_wrappers"
    "test_multifit_herbert"
    "test_object_containers"
    "test_serializers"
    "test_utilities_her_geometry"
    "test_utilities_her_scientific"
    "test_utilities_herbert"
    "test_xunit_framework"
)

set(HERBERT_SYSTEM_TESTS
    "test_mpi/test_job_dispatcher_herbert"
    "test_mpi/test_job_dispatcher_mpiexec"
    "test_mpi/test_job_dispatcher_parpool"
    "test_mpi/test_job_dispatcher_slurm"
    "test_mpi/test_ParpoolMPI_Framework"
)

set(HORACE_TESTS
    "test_algorithms"
    "test_ascii_column_data"
    "test_change_crystal"
    "test_combine"
    "test_dnd_class"
    "test_experiment"
    "test_gen_sqw_for_powders"
    "test_mex_nomex"
    "test_main_header"
    "test_multifit"
    "test_rebin"
    "test_sqw"
    "test_sqw_class"
    "test_sqw_file"
    "test_sqw_pageOpMethods"
    "test_sqw_pixels"
    "test_sym_op"
    "test_symmetrisation"
    "test_transformation"
    "test_utilities"
)

set(HORACE_SYSTEM_TESTS
    "test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_herbert"
    "test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_mex"
    "test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_nomex"
    "test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_parpool"
    "test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_slurm"
    "test_TF_components"
    "test_TF_let"
    "test_TF_refine_crystal"
)
message(" TESTING AGAINST MATLAB VERSION: ${Matlab_RELEASE}")
IF ("${CMAKE_SYSTEM_NAME}" MATCHES "Windows")
    if ("${Matlab_RELEASE}" STREQUAL "R2018b")
    # Run tests for 2018b Matlab on Windows Jenkins in reverse order
    # to avoid running parallel tests simultaneously with other version(s).
    #
       list(REVERSE TEST_DIRECTORIES_HORACE)
    endif()
ENDIF()

#-------------------------------------------------------------------------------
# Combine all the tests into single variable
set(TEST_SUITES
    "${HERBERT_TESTS}"
    "${HERBERT_SYSTEM_TESTS}"
    "${HORACE_TESTS}"
    "${HORACE_SYSTEM_TESTS}"
)

# ------------------------------------------------------------------------------
# Add the local_init directory - which contains worker_v4 and herbert_on -
# to the MATLABPATH environment variable when tests are run.
# This adds the paths to every new Matlab session, so parallel workers can
# access the scripts in tests.
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

set(TEST_TIMEOUT_LENGTH "600") # 10 minutes

foreach(_test_dir ${TEST_SUITES})
    if("${_test_dir}" STREQUAL "test_sqw")
        set(TEST_TIMEOUT_LENGTH "2000")  # 33.3 minutes
    elseif("${_test_dir}" STREQUAL "test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_mex")
        set(TEST_TIMEOUT_LENGTH "2400")  # 40 minutes
    elseif("${_test_dir}" STREQUAL "test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_nomex")
        set(TEST_TIMEOUT_LENGTH "2400")  # 40 minutes
    elseif("${_test_dir}" STREQUAL "test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_parpool")
        set(TEST_TIMEOUT_LENGTH "2400")  # 40 minutes
    elseif("${_test_dir}" STREQUAL "test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_herbert")
        set(TEST_TIMEOUT_LENGTH "2400")  # 40 minutes.
    elseif("${_test_dir}" STREQUAL "test_TF_components")
        set(TEST_TIMEOUT_LENGTH "2100")  # 35 minutes
     elseif("${_test_dir}" STREQUAL "test_TF_let")
        set(TEST_TIMEOUT_LENGTH "2100")  # 35 minutes
    elseif("${_test_dir}" STREQUAL "test_TF_refine_crystal")
        set(TEST_TIMEOUT_LENGTH "1800")  # 30 minutes
    elseif("${_test_dir}" STREQUAL "test_algorithms")
        set(TEST_TIMEOUT_LENGTH "2400")  # 40 minutes -- fail due to timeout on windows VM-s
    else()
        set(TEST_TIMEOUT_LENGTH "1200")  # 20 minutes
    endif()

    set(TEST_NAME "Matlab.${_test_dir}")
    matlab_add_unit_test(
        NAME "${TEST_NAME}"
        CUSTOM_TEST_COMMAND "validate_horace ${_test_dir} -talkative -disp_skipped -forcemex -exit_on_completion"
        ADDITIONAL_PATH "${Horace_ROOT}/admin"
        TIMEOUT ${TEST_TIMEOUT_LENGTH})
    set_tests_properties("${TEST_NAME}"
        PROPERTIES
            ENVIRONMENT "${ENV_VARIABLES}"
            TIMEOUT ${TEST_TIMEOUT_LENGTH}
    )
endforeach()
