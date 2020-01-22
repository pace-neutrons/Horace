set(
    SRC_FILES
    "mtimesx_mex.cpp"
)

set(
    HDR_FILES
    "../CommonCode.h"
    "MatMultiply.h"
)

set(MEX_NAME "mtimesx_mex")
horace_add_mex(
    NAME "${MEX_NAME}"
    SRC "${SRC_FILES}" "${HDR_FILES}"
)
if(OpenMP_CXX_FOUND)
    target_link_libraries("${MEX_NAME}" OpenMP::OpenMP_CXX)
endif()
