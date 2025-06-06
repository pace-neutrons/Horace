set(TEST_NAME "cpp_communicator.test")

set(TEST_SRC_FILES
    "cpp_communicator_test.cpp"
)

set(SRC_FILES
    "${CXX_SOURCE_DIR}/cpp_communicator/cpp_communicator.cpp"
    "${CXX_SOURCE_DIR}/cpp_communicator/input_parser.cpp"
    "${CXX_SOURCE_DIR}/cpp_communicator/MPI_wrapper.cpp"
    "${CXX_SOURCE_DIR}/utility/environment.cpp"
)

set(HDR_FILES
    "${CXX_SOURCE_DIR}/cpp_communicator/cpp_communicator.h"
    "${CXX_SOURCE_DIR}/cpp_communicator/input_parser.h"
    "${CXX_SOURCE_DIR}/cpp_communicator/MPI_wrapper.h"
    "${CXX_SOURCE_DIR}/utility/environment.h"
)
#
set(LIBS
    "${Matlab_UT_LIBRARY}"
    "${Matlab_MX_LIBRARY}"
)


pace_add_cpp_unit_test(
    NAME "${TEST_NAME}"
    SOURCES "${SRC_FILES}" "${HDR_FILES}" "${TEST_SRC_FILES}"
    LIBRARIES "${LIBS}"
    MEX_TEST
)
target_include_directories("${TEST_NAME}" PRIVATE "${MPI_CXX_INCLUDE_PATH}")
target_link_libraries("${TEST_NAME}" "${MPI_CXX_LIBRARIES}")