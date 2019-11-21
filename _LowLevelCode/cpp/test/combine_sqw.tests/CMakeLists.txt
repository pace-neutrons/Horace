set(TEST_NAME "combine_sqw.test")

set(TEST_SRC_FILES
    "combine_sqw.test.cpp"
)

set(SRC_FILES
    "combine_sqw.test.cpp"
    "../../combine_sqw/combine_sqw.cpp"
    "../../combine_sqw/exchange_buffer.cpp"
    "../../combine_sqw/fileParameters.cpp"
    "../../combine_sqw/nsqw_pix_reader.cpp"
    "../../combine_sqw/pix_mem_map.cpp"
    "../../combine_sqw/sqw_pix_writer.cpp"
    "../../combine_sqw/sqw_reader.cpp"
)

set(HDR_FILES
    "../../combine_sqw/combine_sqw.h"
    "../../combine_sqw/exchange_buffer.h"
    "../../combine_sqw/fileParameters.h"
    "../../combine_sqw/nsqw_pix_reader.h"
    "../../combine_sqw/pix_mem_map.h"
    "../../combine_sqw/sqw_pix_writer.h"
    "../../combine_sqw/sqw_reader.h"
)

set(LIBS
    "${Matlab_UT_LIBRARY}"
)

add_executable("${TEST_NAME}"
    ${TEST_SRC_FILES}
    ${TEST_HDR_FILES}
    ${SRC_FILES}
    ${HDR_FILES}
)
target_include_directories("${TEST_NAME}" PRIVATE
    "${CMAKE_SOURCE_DIR}/_LowLevelCode/cpp"
    "${Matlab_INCLUDE_DIRS}"
)
target_link_libraries("${TEST_NAME}"
    gtest_main
    "${Matlab_MEX_LIBRARY}"
    "${Matlab_MX_LIBRARY}"
    "${LIBS}"
)
set_target_properties("${TEST_NAME}" PROPERTIES
    FOLDER "Tests"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/tests/bin"
)
add_test(
    NAME "${CMAKE_BINARY_DIR}/tests/bin/${TEST_NAME}"
    COMMAND "${TEST_NAME}"
)
