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
    # "test_spinw_integration"
    "test_sqw"
    "test_sqw_file"
    "test_symmetrisation"
    "test_sym_op"
    "test_tobyfit"
    "test_transformation"
    "test_utilities"
)

set(TEST_TIMEOUT_LENGTH "1200")  # 20 minutes

foreach(_test_dir ${TEST_DIRECTORIES})
    set(TEST_NAME "Matlab.${_test_dir}")
    matlab_add_unit_test(
        NAME "${TEST_NAME}"
        CUSTOM_TEST_COMMAND
            "try;\
                herbert_init;\
                horace_init;\
                hc = herbert_config;\
                hc.init_tests = true;\
                pc = parallel_config;\
                pc.parallel_framework = 'mpiexec_mpi';\
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
    # The MPI tests require that `herbert_on.m` be on the path for all workers
    # when Matlab starts up: add the path of the directory it's copied into
    # to the MATLABPATH environment variable when tests are run.
    set_tests_properties("${TEST_NAME}"
        PROPERTIES
            ENVIRONMENT "MATLABPATH=${MATLABPATH}:${CMAKE_BINARY_DIR}/horace_config"
    )
endforeach()
