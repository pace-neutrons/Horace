set(
    SRC_FILES
    "recompute_bin_data_c.cpp"
)

set(
    HDR_FILES
    "../../build_all/CommonCode.h"
    "recompute_bin_data.h"
)

set(MEX_NAME "recompute_bin_data_c")
matlab_add_mex(
    NAME "${MEX_NAME}"
    SRC "${SRC_FILES}" "${HDR_FILES}"
)
if(OpenMP_CXX_FOUND)
    target_link_libraries("${MEX_NAME}" OpenMP::OpenMP_CXX)
endif()
