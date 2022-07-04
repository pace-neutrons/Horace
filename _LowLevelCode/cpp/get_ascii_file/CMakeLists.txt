set(SRC_FILES
    "get_ascii_file.cpp"
    "IIget_ascii_file.cpp"
)

set(HDR_FILES
    "get_ascii_file.h"
)

set(MEX_NAME "get_ascii_file")
pace_add_mex(
    NAME "${MEX_NAME}"
    SRC "${SRC_FILES}" "${HDR_FILES}"
)
target_include_directories("${MEX_NAME}" PRIVATE "${CXX_SOURCE_DIR}")
