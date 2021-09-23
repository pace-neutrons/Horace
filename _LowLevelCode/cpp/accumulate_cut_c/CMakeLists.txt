set(
    SRC_FILES
    "accumulate_cut_c.cpp"
)

set(
    HDR_FILES
    "../CommonCode.h"
    "accumulate_cut_c.h"
)

set(MEX_NAME "accumulate_cut_c")
pace_add_mex(
    NAME "${MEX_NAME}"
    SRC "${SRC_FILES}" "${HDR_FILES}"
)
if(${OPENMP_FOUND})
    target_compile_options("${MEX_NAME}" PRIVATE ${OpenMP_CXX_FLAGS})
    target_link_options("${MEX_NAME}" PRIVATE ${OpenMP_EXE_LINKER_FLAGS})
endif()

#if (OPENMP_FOUND)
#    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
#    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
#    set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_EXE_LINKER_FLAGS}")
#endif()