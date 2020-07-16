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
    LINK_TO "${OpenMP_CXX_FLAGS}"
)
if(${OPENMP_FOUND})
    target_compile_options("${MEX_NAME}" PRIVATE ${OpenMP_CXX_FLAGS})
endif()
