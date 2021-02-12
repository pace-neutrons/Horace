set(CXX_TEST_DIR "${CMAKE_CURRENT_LIST_DIR}")
set(TESTS_BIN_DIR "${CMAKE_BINARY_DIR}/tests/bin")

include(PACE_AddCppUnitTest)

set(TEST_DIRS
    cpp_communicator.tests
    get_ascii_file.tests
    utility.tests
)
foreach(_test_dir ${TEST_DIRS})
    add_subdirectory(${_test_dir})
endforeach()
