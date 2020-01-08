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
herbert_add_mex(
    NAME "${MEX_NAME}"
    SRC "${SRC_FILES}" "${HDR_FILES}"
)
target_include_directories("${MEX_NAME}" PRIVATE "${MPI_CXX_INCLUDE_PATH}")
target_link_libraries("${MEX_NAME}" "${MPI_CXX_LIBRARIES}")
