set(TEST_DIRECTORIES
    "test_ascii_column_data"
    "test_change_crystal"
    "test_combine"
    "test_dnd"
    "test_gen_sqw_for_powders"
    "test_herbert_utilites"
    "test_mex_nomex"
    "test_mslice_utilities"
    "test_multifit"
    "test_rebin"
    "test_spinw_integration"
    "test_sqw"
    "test_sqw_file"
    "test_symmetrisation"
    "test_sym_op"
    "test_tobyfit"
    "test_transformation"
    "test_utilities"
)

foreach(_test_dir ${TEST_DIRECTORIES})
    if("${_test_dir}" STREQUAL "test_tobyfit")
        set(TEST_TIMEOUT_LENGTH "1020")  # 17 minutes
    else()
        set(TEST_TIMEOUT_LENGTH "420")  # 6 minutes
    endif()

    set(TEST_NAME "Matlab.${_test_dir}")
    matlab_add_unit_test(
        NAME "${TEST_NAME}"
        CUSTOM_TEST_COMMAND
            "try;\
                herbert_init;\
                horace_init;\
                hc = herbert_config;\
                hc.init_tests = true;\
                res = runtests('${CMAKE_SOURCE_DIR}/_test/${_test_dir}');\
            catch ME;\
                disp('Error caught attempting to run test:');\
                disp(ME);\
                exit(1);\
            end;\
            exit(~res)"
        ADDITIONAL_PATH
            "${CMAKE_SOURCE_DIR}/admin"
            "${CMAKE_SOURCE_DIR}/horace_core"
            "${Herbert_ROOT}"
        TIMEOUT ${TEST_TIMEOUT_LENGTH}
    )
endforeach()
