set(
    SRC_FILES
    "calc_projections_c.cpp"
)

set(
    HDR_FILES
    "../CommonCode.h"
    "calc_projections_c.h"
)

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    # On GCC you must pass OpenMP_CXX_FLAGS to the linker
    set(LIBS "${OpenMP_CXX_FLAGS}")
endif()

set(MEX_NAME "calc_projections_c")
pace_add_mex(
    NAME "${MEX_NAME}"
    SRC "${SRC_FILES}" "${HDR_FILES}"
    LINK_TO "${LIBS}"
)
if(${OPENMP_FOUND})
    target_compile_options("${MEX_NAME}" PRIVATE ${OpenMP_CXX_FLAGS})
    target_link_options("${MEX_NAME}" PRIVATE ${OpenMP_EXE_LINKER_FLAGS})
endif()
