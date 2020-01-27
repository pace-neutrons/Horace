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
)

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
    file(TO_CMAKE_PATH "$ENV{MATLABPATH}" MATLABPATH)
    # The MPI tests require that `herbert_on.m` be on the path for all workers
    # when Matlab starts up: add the path of the directory it's copied into
    # to the MATLABPATH environment variable when tests are run.
    set_tests_properties("${TEST_NAME}"
        PROPERTIES
            ENVIRONMENT "MATLABPATH=${MATLABPATH}:${CMAKE_BINARY_DIR}/herbert_config"
    )
endforeach()
