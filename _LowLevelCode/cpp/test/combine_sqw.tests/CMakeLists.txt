
set(TEST_NAME "CombineSQW.test")
set(SRC_FILES
    "combine_sqw.test.cpp")
set(LIBS
    "combine_sqw")

add_executable("${TEST_NAME}" "${SRC_FILES}")
target_link_libraries("${TEST_NAME}" "${LIBS}" gtest_main ${Matlab_MEX_LIBRARY})
target_include_directories("${TEST_NAME}" PRIVATE
    "${CMAKE_SOURCE_DIR}/_LowLevelCode/cpp"
    "${Matlab_INCLUDE_DIRS}")
add_test(
    NAME "${TEST_NAME}"
    COMMAND "${TEST_NAME}")
set_target_properties("${TEST_NAME}" PROPERTIES FOLDER "Tests")
