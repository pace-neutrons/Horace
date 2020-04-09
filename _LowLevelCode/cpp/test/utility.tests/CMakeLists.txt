set(TEST_SRC_FILES
    "utility.test.cpp"
)

set(HDR_FILES
    "${CXX_SOURCE_DIR}/utility/version.h"
)

set(TEST_NAME "utility.test")
pace_add_cpp_unit_test(
    NAME "${TEST_NAME}"
    SOURCES "${TEST_SRC_FILES}" "${HDR_FILES}"
)
