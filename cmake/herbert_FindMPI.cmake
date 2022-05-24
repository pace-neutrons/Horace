set(EXTERNAL_ROOT "${Horace_ROOT}/_LowLevelCode/external")
if(UNIX)
    if (USE_HORACE_MPI)
        set(MPICH_VERSION "3.3a2")
        set(MPI_ROOT "${EXTERNAL_ROOT}/glnxa64/mpich-${MPICH_VERSION}")
    endif()
    message(STATUS "looking for MPI in at: ${MPI_ROOT}")
    # We point CMake to the mpicc and mpicxx compiler scripts, these are then
    # used by CMake's "Find" script to find the relevant libraries that we
    # package with Horace
    find_file(
        MPI_C_COMPILER
        NAMES "mpicc"
        PATHS "${MPI_ROOT}/bin"
        DOC "Path to C MPI compiler script"
        NO_DEFAULT_PATH)
    message(STATUS "found mpicc at: ${MPI_C_COMPILER}")
    find_file(
        MPI_CXX_COMPILER
        NAMES "mpicxx"
        PATHS "${MPI_ROOT}/bin"
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


if (MPI_FOUND)
   list(GET MPI_CXX_LIBRARIES 0 libPATH)
   get_filename_component(libPATH ${libPATH} DIRECTORY)
   get_filename_component(MPI_TEST_ROOT ${libPATH} DIRECTORY)
   file(TO_CMAKE_PATH "${MPI_TEST_ROOT}/" MPI_TEST_ROOT)
   if (NOT ${MPI_TEST_ROOT} STREQUAL "")
      set(MPI_ROOT ${MPI_TEST_ROOT})
      message(STATUS "Found MPI_ROOT at: ${MPI_ROOT}")
   endif()
endif()
