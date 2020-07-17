set(TEST_SRC_FILES
    "compute_pix_sums.test.cpp"
)

set(HDR_FILES
    "${CXX_SOURCE_DIR}/compute_pix_sums/compute_pix_sums.h"
    "${CXX_SOURCE_DIR}/test/compute_pix_sums.tests/compute_pix_sums.test.h"
)

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    # On GCC you must pass OpenMP_CXX_FLAGS to the linker
    set(LIBS "${OpenMP_CXX_FLAGS}")
endif()
set(LIBS "${LIBS}" gmock)

set(TEST_NAME "compute_pix_sums.test")
pace_add_cpp_unit_test(
    NAME "${TEST_NAME}"
    SOURCES "${TEST_SRC_FILES}" "${HDR_FILES}"
    LIBRARIES "${LIBS}"
    MEX_TEST
)
if (${OPENMP_FOUND})
    target_compile_options("${TEST_NAME}" PRIVATE "${OpenMP_CXX_FLAGS}")
endif()
