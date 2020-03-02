if(UNIX)
    set(EXTERNAL_ROOT "${CMAKE_SOURCE_DIR}/herbert_core/external")
    set(MPICH_VERSION "3.3a2")
    set(MPICH_ROOT "${EXTERNAL_ROOT}/glnxa64/mpich-${MPICH_VERSION}")

    # We point CMake to the mpicc and mpicxx compiler scripts, these are then
    # used by CMake's "Find" script to find the relevant libraries that we
    # package with Herbert
    find_file(MPI_C_COMPILER
        NAMES "mpicc"
        PATHS "${MPICH_ROOT}/bin"
        DOC "Path to C MPI compiler script"
        NO_DEFAULT_PATH
    )
    find_file(MPI_CXX_COMPILER
        NAMES "mpicxx"
        PATHS "${MPICH_ROOT}/bin"
        DOC "Path to CXX MPI compiler script"
        NO_DEFAULT_PATH
    )
endif()

find_package(MPI REQUIRED)
