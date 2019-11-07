set(
    SRC_FILES
    "bin_pixels_c.cpp"
)

set(
    HDR_FILES
    "../../build_all/CommonCode.h"
)

set(MEX_NAME "bin_pixels_c")
matlab_add_mex(
    NAME "${MEX_NAME}"
    SRC "${SRC_FILES}" "${HDR_FILES}"
)
