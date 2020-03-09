set(
    SRC_FILES
    "bin_pixels_c.cpp"
)

set(
    HDR_FILES
    "../CommonCode.h"
)

set(MEX_NAME "bin_pixels_c")
pace_add_mex(
    NAME "${MEX_NAME}"
    SRC "${SRC_FILES}" "${HDR_FILES}"
    COPY_TO "${CMAKE_SOURCE_DIR}/horace_core/DLL"
)
