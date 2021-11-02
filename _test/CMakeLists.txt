set(TEST_DIRECTORIES
    "test_data_loaders"
    "test_config"
    "test_IX_classes"
    "test_map_mask"
    "test_multifit"
    "test_utilities"
    "test_serializers"
    "test_instrument_classes"
    "test_docify"
    "test_geometry"
    "test_admin"
    "test_xunit_framework"
    "test_mpi_wrappers"
    "test_mpi/test_job_dispatcher_herbert"
    "test_mpi/test_job_dispatcher_mpiexec"
    "test_mpi/test_job_dispatcher_parpool"
    "test_mpi/test_job_dispatcher_slurm"
    "test_mpi/test_ParpoolMPI_Framework")

# Add the local_init directory - which contains worker_v2 and herbert_on -
# to the MATLABPATH environment variable when tests are run.
# This adds the paths to every new Matlab session, so parallel workers can
# access the scripts in tests.
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
    "TMP=${CMAKE_BINARY_DIR}/tests")

set(TEST_TIMEOUT_LENGTH "600") # 10 minutes
foreach(_test_dir ${TEST_DIRECTORIES})
    set(TEST_NAME "Matlab.${_test_dir}")
    matlab_add_unit_test(
        NAME
        "${TEST_NAME}"
        CUSTOM_TEST_COMMAND
        "validate_herbert ${_test_dir} -verbose -exit_on_completion"
        ADDITIONAL_PATH
        "${Herbert_ROOT}/admin"
        TIMEOUT
        ${TEST_TIMEOUT_LENGTH})
    set_tests_properties("${TEST_NAME}"
        PROPERTIES ENVIRONMENT "${ENV_VARIABLES}")
endforeach()

# =============================================================================
# Install commands
# =============================================================================
install(
    DIRECTORY "shared"
    DESTINATION "Herbert/_test"
    USE_SOURCE_PERMISSIONS
    PATTERN "*.m~" EXCLUDE
    PATTERN "*.asv" EXCLUDE)
