set(
    SRC_FILES
    "bin_io_handler.cpp"
    "mex_bin_plugin.cpp"
)

set(
    HDR_FILES
    "${CXX_SOURCE_DIR}/include/CommonCode.h"
    "bin_io_handler.h"
)

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    # On GCC you must pass OpenMP_CXX_FLAGS to the linker
    set(LIBS "${OpenMP_CXX_FLAGS}")
endif()

set(MEX_NAME "mex_bin_plugin")
pace_add_mex(
    NAME "${MEX_NAME}"
    SRC "${SRC_FILES}" "${HDR_FILES}"
    LINK_TO "${LIBS}"
)
if(${OPENMP_FOUND})
    target_compile_options("${MEX_NAME}" PRIVATE ${OpenMP_CXX_FLAGS})
    target_link_options("${MEX_NAME}" PRIVATE ${OpenMP_EXE_LINKER_FLAGS})
endif()
