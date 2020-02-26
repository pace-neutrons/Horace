set(TEST_DIRECTORIES
    "test_data_loaders"
    "test_config"
    "test_IX_classes"
    "test_map_mask"
    # "test_mslice_objects"
    "test_multifit"
    "test_multifit_legacy"
    "test_utilities"
    "test_instrument_classes"
    "test_docify"
    "test_admin"
    # "test_mpi"
    "test_mpi_wrappers"
)
# The MPI tests require that `herbert_on.m` be on the path for all workers
# when Matlab starts up: add the local_init directory - which contains
# these files - to the MATLABPATH environment variable when tests are run.
file(TO_CMAKE_PATH "$ENV{MATLABPATH}" MATLAB_PATH)
if(WIN32)
    set(PATH_SEPARATOR "\;")
else()
    set(PATH_SEPARATOR ":")
endif()
set(MATLAB_PATH "${MATLAB_PATH}${PATH_SEPARATOR}${CMAKE_BINARY_DIR}/local_init")

foreach(_test_dir ${TEST_DIRECTORIES})
    set(TEST_NAME "Matlab.${_test_dir}")
    matlab_add_unit_test(
        NAME "${TEST_NAME}"
        CUSTOM_TEST_COMMAND
            "try;\
                herbert_init;\
                res = runtests('${CMAKE_SOURCE_DIR}/_test/${_test_dir}');\
            catch ME;\
                disp('Error caught attempting to run test:');\
                disp(ME);\
                exit(1);\
            end;\
            exit(~res)"
        ADDITIONAL_PATH
            "${CMAKE_SOURCE_DIR}/admin"
            "${CMAKE_SOURCE_DIR}/herbert_core"
        TIMEOUT 300  # 5 mins
    )
    set_tests_properties("${TEST_NAME}"
        PROPERTIES
            ENVIRONMENT "MATLABPATH=${MATLAB_PATH}"
    )
endforeach()

# =============================================================================
# Install commands
# =============================================================================
install(
    DIRECTORY "shared"
    DESTINATION "Herbert/_test"
    USE_SOURCE_PERMISSIONS
    PATTERN "*.m~" EXCLUDE
    PATTERN "*.asv" EXCLUDE
)
