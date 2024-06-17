set(TEST_SRC_FILES
    "mex_bin_plugin.test.cpp"
)

set(SRC_FILES
    "${CXX_SOURCE_DIR}/get_ascii_file/mex_bin_plugin.cpp"
    "${CXX_SOURCE_DIR}/utility/environment.cpp"
)

set(HDR_FILES
    "${CXX_SOURCE_DIR}/get_ascii_file/mex_bin_plugin.hpp"
    "${CXX_SOURCE_DIR}/utility/environment.h"
)

pace_add_cpp_unit_test(
    NAME "get_ascii_file.test"
    SOURCES "${TEST_SRC_FILES}" "${SRC_FILES}" "${HDR_FILES}"
    MEX_TEST
)
