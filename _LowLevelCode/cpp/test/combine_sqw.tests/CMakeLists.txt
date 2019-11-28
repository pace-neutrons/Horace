set(TEST_NAME "combine_sqw.test")

set(TEST_SRC_FILES
    "combine_sqw.test.cpp"
)

set(SRC_FILES
    "${CXX_SOURCE_DIR}/combine_sqw/combine_sqw.cpp"
    "${CXX_SOURCE_DIR}/combine_sqw/exchange_buffer.cpp"
    "${CXX_SOURCE_DIR}/combine_sqw/fileParameters.cpp"
    "${CXX_SOURCE_DIR}/combine_sqw/nsqw_pix_reader.cpp"
    "${CXX_SOURCE_DIR}/combine_sqw/pix_mem_map.cpp"
    "${CXX_SOURCE_DIR}/combine_sqw/sqw_pix_writer.cpp"
    "${CXX_SOURCE_DIR}/combine_sqw/sqw_reader.cpp"
    "${CXX_SOURCE_DIR}/utility/environment.cpp"
)

set(HDR_FILES
    "${CXX_SOURCE_DIR}/combine_sqw/combine_sqw.h"
    "${CXX_SOURCE_DIR}/combine_sqw/exchange_buffer.h"
    "${CXX_SOURCE_DIR}/combine_sqw/fileParameters.h"
    "${CXX_SOURCE_DIR}/combine_sqw/nsqw_pix_reader.h"
    "${CXX_SOURCE_DIR}/combine_sqw/pix_mem_map.h"
    "${CXX_SOURCE_DIR}/combine_sqw/sqw_pix_writer.h"
    "${CXX_SOURCE_DIR}/combine_sqw/sqw_reader.h"
    "${CXX_SOURCE_DIR}/utility/environment.h"
)

set(LIBS
    "${Matlab_UT_LIBRARY}"
)

horace_add_unit_test(
    NAME "${TEST_NAME}"
    SOURCES "${SRC_FILES}" "${HDR_FILES}" "${TEST_SRC_FILES}"
    LIBRARIES "${LIBS}"
    MEX_TEST
)
