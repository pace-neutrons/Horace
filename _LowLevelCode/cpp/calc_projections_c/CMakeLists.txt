set(
    SRC_FILES
    "calc_projections_c.cpp"
)

set(
    HDR_FILES
    "../CommonCode.h"
    "calc_projections_c.h"
)

set(MEX_NAME "calc_projections_c")
pace_add_mex(
    NAME "${MEX_NAME}"
    SRC "${SRC_FILES}" "${HDR_FILES}"
    COPY_TO "${CMAKE_SOURCE_DIR}/horace_core/DLL"
)
if(OpenMP_CXX_FOUND)
    target_link_libraries("${MEX_NAME}" OpenMP::OpenMP_CXX)
endif()
