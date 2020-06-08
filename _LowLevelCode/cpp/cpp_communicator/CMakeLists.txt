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
set(COPY_DESTINATION "${CMAKE_SOURCE_DIR}/herbert_core/DLL")
pace_add_mex(
    NAME "${MEX_NAME}"
    SRC "${SRC_FILES}" "${HDR_FILES}"
    COPY_TO "${COPY_DESTINATION}"
)
target_include_directories("${MEX_NAME}"
    PRIVATE "${CXX_SOURCE_DIR}"
    PRIVATE "${MPI_CXX_INCLUDE_PATH}")
target_link_libraries("${MEX_NAME}" "${MPI_CXX_LIBRARIES}")

if(UNIX)
    # For MPICH on Linux we need to set relative RPATH values so dynamic libs
    # can be located by the mex library
    file(RELATIVE_PATH _mpich_lib_file "${COPY_DESTINATION}" "${MPI_LIBRARY}")
    get_filename_component(_mpich_lib_dir "${_mpich_lib_file}" DIRECTORY)
    set_target_properties("${MEX_NAME}"
        PROPERTIES
            BUILD_RPATH "${_mpich_lib_dir}"
            INSTALL_RPATH "${_mpich_lib_dir}"
    )
endif()
