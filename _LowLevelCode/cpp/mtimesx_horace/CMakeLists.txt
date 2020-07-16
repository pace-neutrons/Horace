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
pace_add_mex(
    NAME "${MEX_NAME}"
    SRC "${SRC_FILES}" "${HDR_FILES}"
    COPY_TO "${CMAKE_SOURCE_DIR}/horace_core/DLL"
)
if (${OPENMP_FOUND})
    target_compile_options("${MEX_NAME}" PRIVATE ${OpenMP_CXX_FLAGS})
endif()