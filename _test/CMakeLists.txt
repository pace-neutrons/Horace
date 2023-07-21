# ========================================================================
# ========================================================================
# ===                                                                  ===
# ===  Please ensure that any alterations you make to the directories  ===
# ===  in TEST_DIRECTORIES_HERBERT and TEST_DIRECTORIES_HORACE are     ===
# ===  also made in validate_horace.m                                  ===
# ===                                                                  ===
# ===  This will ensure that they perform the same tests.              ===
# ===                                                                  ===
# ===  [Automatic synchronisation by e.g. reading this file            ===
# ===   would solve the manual unreliability of this step]             ===
# ===                                                                  ===
# ===                                                                  ===
# ========================================================================
# ========================================================================

set(TEST_DIRECTORIES_HORACE
    "test_admin"
    "test_data_loaders"
    "test_config"
    "test_IX_classes"
    "test_map_mask"
    "test_multifit_herbert"
    "test_utilities_herbert"
    "test_serializers"
    "test_instrument_classes"
    "test_unique_objects_container"
    "test_docify"
    "test_geometry"
    "test_xunit_framework"
    "test_mpi_wrappers"
    "test_mpi/test_ParpoolMPI_Framework"
    "test_mpi/test_job_dispatcher_herbert"
    "test_mpi/test_job_dispatcher_mpiexec"
    "test_mpi/test_job_dispatcher_parpool"
    "test_mpi/test_job_dispatcher_slurm"
    "test_algorithms"
    "test_ascii_column_data"
    "test_change_crystal"
    "test_combine"
    "test_dnd_class"
    "test_experiment"
    "test_gen_sqw_for_powders"
    "test_rebin"
    "test_mex_nomex"
    "test_main_header"
    "test_sqw"
    "test_sqw_class"
    "test_sqw_file"
    "test_sqw_pixels"
    "test_sym_op"
    "test_symmetrisation"
    "test_transformation"
    "test_utilities"
    "test_multifit"
    "test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_mex"
    "test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_nomex"
    "test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_herbert"
    "test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_parpool"
    "test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_slurm"
    "test_TF_components"
    "test_TF_let"
    "test_TF_refine_crystal"
)

# Add the local_init directory - which contains worker_v2 and herbert_on -
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

foreach(_test_dir ${TEST_DIRECTORIES_HORACE})
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
        CUSTOM_TEST_COMMAND "validate_horace ${_test_dir} -talkative -forcemex -exit_on_completion"
        ADDITIONAL_PATH "${Horace_ROOT}/admin"
        TIMEOUT ${TEST_TIMEOUT_LENGTH})
    set_tests_properties("${TEST_NAME}"
        PROPERTIES
            ENVIRONMENT "${ENV_VARIABLES}"
            TIMEOUT ${TEST_TIMEOUT_LENGTH}
    )
endforeach()
