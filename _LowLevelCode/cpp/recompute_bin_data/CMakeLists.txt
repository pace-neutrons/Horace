set(
    SRC_FILES
    "recompute_bin_data_c.cpp"
)

set(
    HDR_FILES
    "../CommonCode.h"
    "recompute_bin_data_c.h"
    "recompute_pix_sums.h"
)

set(MEX_NAME "recompute_bin_data_c")
pace_add_mex(
    NAME "${MEX_NAME}"
    SRC "${SRC_FILES}" "${HDR_FILES}"
    COPY_TO "${CMAKE_SOURCE_DIR}/horace_core/DLL"
)
if(OpenMP_CXX_FOUND)
    target_link_libraries("${MEX_NAME}" OpenMP::OpenMP_CXX)
endif()
