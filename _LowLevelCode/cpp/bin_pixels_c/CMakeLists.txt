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
)
if(${OPENMP_FOUND})
    target_compile_options("${MEX_NAME}" PRIVATE ${OpenMP_CXX_FLAGS})
    target_link_options("${MEX_NAME}" PRIVATE ${OpenMP_EXE_LINKER_FLAGS})
endif()
