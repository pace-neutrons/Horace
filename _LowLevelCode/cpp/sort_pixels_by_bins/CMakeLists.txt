set(
    SRC_FILES
    "sort_pixels_by_bins.cpp"
)

set(
    HDR_FILES
    "../CommonCode.h"
    "sort_pixels_by_bins.h"
)

set(MEX_NAME "sort_pixels_by_bins")
pace_add_mex(
    NAME "${MEX_NAME}"
    SRC "${SRC_FILES}" "${HDR_FILES}"
)
# openmp is currently disabled here but it may be used in a future
#if(${OPENMP_FOUND})
#    target_compile_options("${MEX_NAME}" PRIVATE ${OpenMP_CXX_FLAGS})
#    target_link_options("${MEX_NAME}" PRIVATE ${OpenMP_EXE_LINKER_FLAGS})
#endif()
