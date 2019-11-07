set(
    SRC_FILES
    "calc_projections_c.cpp"
)

set(
    HDR_FILES
    "../../build_all/CommonCode.h"
    "calc_projections_c.h"
)

set(MEX_NAME "calc_projections_c")
matlab_add_mex(
    NAME "${MEX_NAME}"
    SRC "${SRC_FILES}" "${HDR_FILES}"
)
if(OpenMP_CXX_FOUND)
    target_link_libraries("${MEX_NAME}" OpenMP::OpenMP_CXX)
endif()
