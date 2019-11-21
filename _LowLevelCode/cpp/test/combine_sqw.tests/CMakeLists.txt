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

horace_add_unit_test(
    NAME "${TEST_NAME}"
    SOURCES "${SRC_FILES}" "${HDR_FILES}" "${TEST_SRC_FILES}"
    LIBRARIES "${LIBS}"
    MEX_TEST
)
