set(
    SRC_FILES
    "combine_sqw.cpp"
    "exchange_buffer.cpp"
    "fileParameters.cpp"
    "nsqw_pix_reader.cpp"
    "pix_mem_map.cpp"
    "sqw_pix_writer.cpp"
    "sqw_reader.cpp"
)

set(
    HDR_FILES
    "../../build_all/CommonCode.h"
    "combine_sqw.h"
    "exchange_buffer.h"
    "fileParameters.h"
    "nsqw_pix_reader.h"
    "pix_mem_map.h"
    "sqw_pix_writer.h"
    "sqw_reader.h"
)

set(MEX_NAME "combine_sqw")
matlab_add_mex(
    NAME "${MEX_NAME}"
    SRC "${SRC_FILES}" "${HDR_FILES}"
)
