set(TEST_SRC_FILES
    "sort_pixels_by_bins.test.cpp"
)

set(SRC_FILES
    "${CXX_SOURCE_DIR}/sort_pixels_by_bins/sort_pixels_by_bins.cpp"
)

set(HDR_FILES
    "${CXX_SOURCE_DIR}/sort_pixels_by_bins/sort_pixels_by_bins.h"
    "${CXX_SOURCE_DIR}/CommonCode.h"
)

pace_add_cpp_unit_test(
    NAME "sort_pixels_by_bins.test"
    SOURCES "${TEST_SRC_FILES}" "${SRC_FILES}" "${HDR_FILES}"
    MEX_TEST
)
