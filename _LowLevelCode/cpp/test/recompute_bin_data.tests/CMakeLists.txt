set(TEST_SRC_FILES
    "recompute_pix_sums.test.cpp"
)

set(HDR_FILES
    "${CXX_SOURCE_DIR}/recompute_bin_data/recompute_pix_sums.h"
    "${CXX_SOURCE_DIR}/test/recompute_bin_data.tests/recompute_pix_sums.test.h"
)

set(TEST_NAME "recompute_pix_sums.test")
pace_add_cpp_unit_test(
    NAME "${TEST_NAME}"
    SOURCES "${TEST_SRC_FILES}" "${HDR_FILES}"
    LIBRARIES gmock OpenMP::OpenMP_CXX
    MEX_TEST
)
