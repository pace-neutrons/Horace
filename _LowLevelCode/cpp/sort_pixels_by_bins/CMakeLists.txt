set(
    SRC_FILES
    "sort_pixels_by_bins.cpp"
)

set(
    HDR_FILES
    "../../build_all/CommonCode.h"
    "sort_pixels_by_bins.h"
)

set(MEX_NAME "sort_pixels_by_bins")
matlab_add_mex(
    NAME "${MEX_NAME}"
    SRC "${SRC_FILES}" "${HDR_FILES}"
)
