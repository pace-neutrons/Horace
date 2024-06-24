set(
    SRC_FILES
    "fileParameters.cpp"
    "file_parameters_tester.cpp"
)

set(
    HDR_FILES
    "../CommonCode.h"
    "fileParameters.h"
)

set(MEX_NAME "file_parameters_tester")
pace_add_mex(
    NAME "${MEX_NAME}"
    SRC "${SRC_FILES}" "${HDR_FILES}"
)
# openmp is currently disabled here but it may be used in a future
#if(${OPENMP_FOUND})
#    target_compile_options("${MEX_NAME}" PRIVATE ${OpenMP_CXX_FLAGS})
#    target_link_options("${MEX_NAME}" PRIVATE ${OpenMP_EXE_LINKER_FLAGS})
#endif()
