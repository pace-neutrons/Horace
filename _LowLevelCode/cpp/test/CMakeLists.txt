# Define a macro for adding a test
# function(horace_AddUnitTest TEST_NAME SRC_FILES LIBS)
#     add_executable("${TEST_NAME}" "${SRC_FILES}")
#     target_link_libraries("${TEST_NAME}" "${LIBS}" gtest_main)
#     add_test(
#         NAME "${TEST_NAME}"
#         COMMAND "${TEST_NAME}")
#     set_target_properties("${TEST_NAME}" PROPERTIES FOLDER "Tests")
# endfunction()

set(TEST_DIRECTORIES
    "combine_sqw.tests"
)

foreach(_test_dir ${TEST_DIRECTORIES})
    add_subdirectory("${_test_dir}")
endforeach(_test_dir)
