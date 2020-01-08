set(TEST_DIRECTORIES
    "test_data_loaders"
    "test_config"
    "test_IX_classes"
    "test_map_mask"
    "test_mslice_objects"
    "test_multifit"
    "test_multifit_legacy"
    "test_utilities"
    "test_instrument_classes"
    "test_docify"
    "test_admin"
    "test_mpi"
)

foreach(_test_dir ${TEST_DIRECTORIES})
    matlab_add_unit_test(
        NAME "Matlab.${_test_dir}"
        CUSTOM_TEST_COMMAND
            "try;\
                res = runtests('${CMAKE_SOURCE_DIR}/_test/${_test_dir}');\
            catch ME;\
                disp('Error caught attempting to run test:');\
                disp(ME);\
                exit(1);\
            end;\
            exit(~res)"
        UNITTEST_PRECOMMAND "herbert_init"
        ADDITIONAL_PATH
            "${CMAKE_SOURCE_DIR}/admin"
            "${CMAKE_SOURCE_DIR}/herbert_core"
        TIMEOUT 5400  # 1.5 hours
    )
endforeach()
