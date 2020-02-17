set(
    SRC_FILES
    "accumulate_cut_c.cpp"
)

set(
    HDR_FILES
    "../CommonCode.h"
    "accumulate_cut_c.h"
)

set(MEX_NAME "accumulate_cut_c")
horace_add_mex(
    NAME "${MEX_NAME}"
    SRC "${SRC_FILES}" "${HDR_FILES}"
)
