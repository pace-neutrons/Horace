set(TEST_SRC_FILES
    "IIget_ascii_file.test"
)

set(SRC_FILES
    "${CXX_SOURCE_DIR}/get_ascii_file/IIget_ascii_file.cpp"
)

set(HDR_FILES
    "${CXX_SOURCE_DIR}/get_ascii_file/get_ascii_file.h"
)

herbert_add_unit_test(
    NAME "get_ascii_file.test"
    SOURCES "${TEST_SRC_FILES}" "${SRC_FILES}" "${HDR_FILES}"
    MEX_TEST
)
