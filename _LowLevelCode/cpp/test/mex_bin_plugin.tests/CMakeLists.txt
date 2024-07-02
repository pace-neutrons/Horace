set(TEST_SRC_FILES
    "mex_bin_plugin.test.cpp"
)

set(SRC_FILES
    "${CXX_SOURCE_DIR}/mex_bin_plugin/bin_io_handler.cpp"
    "${CXX_SOURCE_DIR}/utility/environment.cpp"
)

set(HDR_FILES
    "${CXX_SOURCE_DIR}/mex_bin_plugin/bin_io_handler.hpp"
    "${CXX_SOURCE_DIR}/utility/environment.h"
)

pace_add_cpp_unit_test(
    NAME "mex_bin_plugin.test"
    SOURCES "${TEST_SRC_FILES}" "${SRC_FILES}" "${HDR_FILES}"
    MEX_TEST
)
