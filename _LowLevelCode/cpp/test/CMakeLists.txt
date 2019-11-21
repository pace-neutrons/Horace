include(horace_AddUnitTest)

set(TEST_DIRECTORIES
    "combine_sqw.tests"
)

foreach(_test_dir ${TEST_DIRECTORIES})
    add_subdirectory("${_test_dir}")
endforeach(_test_dir)
