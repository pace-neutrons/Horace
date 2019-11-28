set(CXX_TEST_DIR "${CMAKE_CURRENT_LIST_DIR}")
set(TESTS_BIN_DIR "${CMAKE_BINARY_DIR}/tests/bin")

# On Windows we need to point the tests to the Matlab dlls. Define a
# TEST_ENV_PATH variable that has the location appended to the system path.
# When adding tests, this can be set as the system path for those tests.
if(WIN32)
    file(TO_CMAKE_PATH "$ENV{PATH}" SYS_PATH)
    set(TEST_ENV_PATH "${SYS_PATH};${Matlab_DLL_DIR};")
    # ';' is a list separator in CMake, so we need to escape it to get the string
    string(REPLACE ";" "\;" TEST_ENV_PATH "${TEST_ENV_PATH}")
endif()

include(herbert_AddUnitTest)

set(TEST_DIRECTORIES
    "get_ascii_file.tests"
)
foreach(_test_dir "${TEST_DIRECTORIES}")
    add_subdirectory("${_test_dir}")
endforeach()
