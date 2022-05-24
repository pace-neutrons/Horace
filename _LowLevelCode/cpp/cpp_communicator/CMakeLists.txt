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
)
target_include_directories("${MEX_NAME}"
    PRIVATE "${CXX_SOURCE_DIR}"
    PRIVATE "${MPI_CXX_INCLUDE_PATH}")
target_link_libraries("${MEX_NAME}" "${MPI_CXX_LIBRARIES}")


if(UNIX)
    # For MPICH on Linux it's necessary to set relative RPATH values so dynamic
    # libraries can be located by the mex library.
    message(STATUS "origin: ${ORIGIN}")
    message(STATUS "MPI root: ${MPI_ROOT}")
    if (USE_HORACE_MPI)
        set(Horace_EXTERNAL_LIB_REL_PATH "\$ORIGIN/external")
    else()
        set(Horace_EXTERNAL_LIB_REL_PATH "${MPI_ROOT}lib")
    endif()
    message(STATUS "link for -rpath: ${Horace_EXTERNAL_LIB_REL_PATH}")
    # Using the recommended BUILD_RPATH property did not work with CMake 3.7 so
    # the link flags are set explicitly.
    get_target_property(_link_flags "${MEX_NAME}" LINK_FLAGS)
    set_target_properties("${MEX_NAME}"
        PROPERTIES
            LINK_FLAGS "${_link_flags} -Wl,-rpath,${Horace_EXTERNAL_LIB_REL_PATH}"
    )
endif()
