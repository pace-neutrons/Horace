set(
    SRC_FILES
    "recompute_bin_data_c.cpp"
    "recompute_bin_data_helpers.cpp"
)

set(
    HDR_FILES
    "../CommonCode.h"
    "recompute_bin_data_helpers.h"
    "recompute_pix_sums.h"
)

set(MEX_NAME "recompute_bin_data_c")
pace_add_mex(
    NAME "${MEX_NAME}"
    SRC "${SRC_FILES}" "${HDR_FILES}"
    COPY_TO "${CMAKE_SOURCE_DIR}/horace_core/DLL"
)
if (${OPENMP_FOUND})
    target_compile_options("${MEX_NAME}" PUBLIC ${OpenMP_CXX_FLAGS})
endif()
