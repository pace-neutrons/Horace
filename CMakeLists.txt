cmake_minimum_required(VERSION 3.15)

set(Horace_ROOT ${CMAKE_CURRENT_LIST_DIR})
file(READ "${Horace_ROOT}/VERSION" _version)
string(STRIP "${_version}" _version)
project("Horace" VERSION "${_version}")

#
cmake_host_system_information(RESULT CMAKE_HOST_SYSTEM_NAME QUERY OS_NAME)

# C++11 is required for GTest
set(CMAKE_CXX_STANDARD 11)

# Sort our targets into folders
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# Set our options
option(BUILD_TESTS "Build the C++ tests" OFF)


# Set CMake policies
if(POLICY CMP0074)
    # Ignore warnings when setting <MODULE>_ROOT variables
    cmake_policy(SET CMP0074 NEW)
endif()
if(POLICY CMP0115)
  cmake_policy(SET CMP0115 NEW)
endif()
if(POLICY CMP0109)
  cmake_policy(SET CMP0109 OLD)
endif()

# Add cmake directory to CMake's path
list(APPEND CMAKE_MODULE_PATH "${Horace_ROOT}/cmake"
     "${Horace_ROOT}/cmake/external" "${Horace_ROOT}/cmake/shared")

# This sets the destination for mex build artefacts (used in PACE_AddMex)
IF(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
   # Mac OS X specific code
   SET(Matlab_ARCH "_MACI64")
   option(USE_HORACE_MPI "Use MPI libraries provided with Horace" OFF)
ELSEIF(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
   SET(Matlab_ARCH "_GLNXA64")
   option(USE_HORACE_MPI "Use MPI libraries provided with Horace" ON)
ELSEIF (${CMAKE_SYSTEM_NAME} MATCHES "Windows")
   SET(Matlab_ARCH "_PCWIN64")
   option(USE_HORACE_MPI "Use MPI libraries provided with Horace" ON)
ELSE()
   message(FATAL_ERROR "OS name ${CMAKE_HOST_SYSTEM_NAME} have not been recognized. HORACE have never been build on such system" )
ENDIF()
set(Horace_DLL_DIRECTORY "${Horace_ROOT}/horace_core/DLL/${Matlab_ARCH}")

# This is the directory that contains herbert_init.m
set(Horace_CORE "${CMAKE_CURRENT_LIST_DIR}/horace_core")
set(Herbert_CORE "${CMAKE_CURRENT_LIST_DIR}/herbert_core")
# This will hold herbert_on.m and worker_v4.m. This directory will hold any
# files needed for "local initialization", the files mentioned are required
# for running tests. So we automatically add this path to the MATLABPATH when
# we run CTest.
set(LOCAL_INIT_DIR "${CMAKE_BINARY_DIR}/local_init")

# Look for packages early so we can exit if they're not found
find_package(OpenMP)
include(PACE_FindMatlab)
include(PACE_Version)
include(PACE_AddMex)
include(PACE_CodeAnalysis)
include(PACE_Docs)
include(horace_FindHDF5)
include(herbert_FindMPI)
include(CTest)
if(BUILD_TESTING)
    include(PACE_FindGTest)
    enable_testing()
endif()

add_subdirectory("_LowLevelCode")
if(BUILD_TESTING)
    add_subdirectory("_test")
endif()
add_subdirectory("_benchmarking")
add_subdirectory("admin")
add_subdirectory("cmake")

# =============================================================================
# Install commands
# =============================================================================
include(PACE_CPackConfig)

if(WIN32)
    # Don't package committed mex files
    set(EXTERNAL_IGNORE_PATTERN "*/external/glnxa64")
endif()

install(
    DIRECTORY "herbert_core/"
    DESTINATION "Horace/herbert_core/"
    USE_SOURCE_PERMISSIONS
    PATTERN "*.m~" EXCLUDE
    PATTERN "*.asv" EXCLUDE
    PATTERN "*.gitignore" EXCLUDE
    PATTERN "${EXTERNAL_IGNORE_PATTERN}" EXCLUDE
)

install(
    FILES "LICENSE" "README.md"
    DESTINATION "Horace"
)

install(
    DIRECTORY "horace_core/"
    DESTINATION "Horace/horace_core/"
    USE_SOURCE_PERMISSIONS
    PATTERN "*.m~" EXCLUDE
    PATTERN "*.asv" EXCLUDE
    PATTERN "*.gitignore" EXCLUDE
)
