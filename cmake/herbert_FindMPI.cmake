set(EXTERNAL_ROOT "${Herbert_ROOT}/_LowLevelCode/external")
if(UNIX)
    set(MPICH_VERSION "3.3a2")
    set(MPICH_ROOT "${EXTERNAL_ROOT}/glnxa64/mpich-${MPICH_VERSION}")

    # We point CMake to the mpicc and mpicxx compiler scripts, these are then
    # used by CMake's "Find" script to find the relevant libraries that we
    # package with Herbert
    find_file(
        MPI_C_COMPILER
        NAMES "mpicc"
        PATHS "${MPICH_ROOT}/bin"
        DOC "Path to C MPI compiler script"
        NO_DEFAULT_PATH)

    find_file(
        MPI_CXX_COMPILER
        NAMES "mpicxx"
        PATHS "${MPICH_ROOT}/bin"
        DOC "Path to CXX MPI compiler script" NO_DEFAULT_PATH)
else()
    # On Windows we just need to set the environment variables that point to the
    # MSMPI includes and binaries - the find_package call will do the rest
    set(MSMPI_VERSION "8.0.12")
    set(MSMPI_ROOT "${EXTERNAL_ROOT}/win64/MSMPI-${MSMPI_VERSION}")
    set(ENV{MSMPI_BIN} "${MSMPI_ROOT}/Bin")
    set(ENV{MSMPI_INC} "${MSMPI_ROOT}/Include")
    set(ENV{MSMPI_LIB64} "${MSMPI_ROOT}/Lib")
endif()

find_package(MPI REQUIRED)
