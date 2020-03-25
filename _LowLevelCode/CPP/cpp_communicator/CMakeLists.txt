set(SRC_FILES
    "cpp_communicator.cpp"
    "input_parser.cpp"
    "MPI_wrapper.cpp"
)

set(HDR_FILES
    "cpp_communicator.h"
    "input_parser.h"
    "MPI_wrapper.h"
)

set(MEX_NAME "cpp_communicator")
pace_add_mex(
    NAME "${MEX_NAME}"
    SRC "${SRC_FILES}" "${HDR_FILES}"
    COPY_TO "${CMAKE_SOURCE_DIR}/herbert_core/DLL"
)
target_include_directories("${MEX_NAME}"
    PRIVATE "${CXX_SOURCE_DIR}"
    PRIVATE "${MPI_CXX_INCLUDE_PATH}")
target_link_libraries("${MEX_NAME}" "${MPI_CXX_LIBRARIES}")
