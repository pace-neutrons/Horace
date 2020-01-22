set(
    SRC_FILES
    "hdf_mex_reader.cpp"
    "hdf_pix_accessor.cpp"
    "input_parser.cpp"
    "pix_block_processor.cpp"
)

set(
    HDR_FILES
    "../CommonCode.h"
    "hdf_mex_reader.cpp"
    "hdf_pix_accessor.cpp"
    "input_parser.cpp"
    "pix_block_processor.cpp"
)

set(MEX_NAME "hdf_mex_reader")
horace_add_mex(
    NAME "${MEX_NAME}"
    SRC "${SRC_FILES}" "${HDR_FILES}"
)
target_include_directories("${MEX_NAME}" PUBLIC "${HDF5_INCLUDE_DIRS}")
target_link_libraries("${MEX_NAME}" "${HDF5_LIBRARIES}")
