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
    # For MPICH on Linux it's necessary to set relative RPATH values so dynamic
    # libraries can be located by the mex library.
    file(RELATIVE_PATH _mpich_lib_file "${COPY_DESTINATION}" "${MPI_LIBRARY}")
    get_filename_component(_mpich_lib_dir "${_mpich_lib_file}" DIRECTORY)
    set(Herbert_MPICH_LIB_RPATH "\$ORIGIN/${_mpich_lib_dir}")
    # Using the recommended BUILD_RPATH property did not work with CMake 3.7 so
    # the link flags are set explicitly.
    get_target_property(_link_flags "${MEX_NAME}" LINK_FLAGS)
    set_target_properties("${MEX_NAME}"
        PROPERTIES
            LINK_FLAGS "${_link_flags} -Wl,-rpath,${Herbert_MPICH_LIB_RPATH}"
    )
endif()
