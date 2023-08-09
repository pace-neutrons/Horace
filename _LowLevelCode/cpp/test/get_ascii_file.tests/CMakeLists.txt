set(TEST_SRC_FILES
    "IIget_ascii_file.test.cpp"
)

set(SRC_FILES
    "${CXX_SOURCE_DIR}/get_ascii_file/IIget_ascii_file.cpp"
    "${CXX_SOURCE_DIR}/utility/environment.cpp"
)

set(HDR_FILES
    "${CXX_SOURCE_DIR}/get_ascii_file/get_ascii_file.h"
    "${CXX_SOURCE_DIR}/utility/environment.h"
)

pace_add_cpp_unit_test(
    NAME "get_ascii_file.test"
    SOURCES "${TEST_SRC_FILES}" "${SRC_FILES}" "${HDR_FILES}"
    MEX_TEST
)
