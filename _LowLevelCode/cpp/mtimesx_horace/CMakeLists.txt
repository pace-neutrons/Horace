set(
    SRC_FILES
    "mtimesx_mex.cpp"
)

set(
    HDR_FILES
    "../CommonCode.h"
    "MatMultiply.h"
)

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    # On GCC you must pass OpenMP_CXX_FLAGS to the linker, doing the same with
    # MSVC generates warnings, so this "if" block is necessary
    set(LIBS "${OpenMP_CXX_FLAGS}")
endif()

set(MEX_NAME "mtimesx_mex")
pace_add_mex(
    NAME "${MEX_NAME}"
    SRC "${SRC_FILES}" "${HDR_FILES}"
    LINK_TO "${LIBS}"
)
if(${OPENMP_FOUND})
    target_compile_options("${MEX_NAME}" PRIVATE ${OpenMP_CXX_FLAGS})
    target_link_options("${MEX_NAME}" PRIVATE ${OpenMP_EXE_LINKER_FLAGS})
endif()
