cmake_minimum_required(VERSION 3.15)

set(Herbert_ROOT ${CMAKE_CURRENT_LIST_DIR})
file(READ "${Herbert_ROOT}/VERSION" _version)
string(STRIP "${_version}" _version)
project("Herbert" VERSION "${_version}")

set(CMAKE_CXX_STANDARD 11)

# Sort our targets into folders
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# Set our options
option(BUILD_TESTS "Build the C++ tests" ON)

# Add cmake directory to CMake's path
list(APPEND CMAKE_MODULE_PATH "${Herbert_ROOT}/cmake"
     "${Herbert_ROOT}/cmake/external" "${Herbert_ROOT}/cmake/shared")

# This sets the destination for mex build artifacts (used in PACE_AddMex)
set(Herbert_DLL_DIRECTORY "${Herbert_ROOT}/herbert_core/DLL")
# This is the directory that contains herbert_init.m
set(Herbert_CORE "${CMAKE_CURRENT_LIST_DIR}/herbert_core")
# This will hold herbert_on.m and worker_v2.m. This directory will hold any
# files needed for "local initialization", the files mentioned are required
# for running tests. So we automatically add this path to the MATLABPATH when
# we run CTest.
set(LOCAL_INIT_DIR "${CMAKE_BINARY_DIR}/local_init")

# Look for packages early so we can exit if they're not found
include(herbert_FindMPI)
include(PACE_FindMatlab)
include(PACE_Version)
include(PACE_AddMex)
include(PACE_CodeAnalysis)
if(${BUILD_TESTS})
    include(CTest)
    include(PACE_FindGTest)
    enable_testing()
endif()

add_subdirectory("_LowLevelCode")
if(${BUILD_TESTS})
    add_subdirectory("_test")
endif()
add_subdirectory("admin")
add_subdirectory("cmake")

# =============================================================================
# Install commands
# =============================================================================
include(PACE_CPackConfig)

install(
    DIRECTORY "herbert_core"
    DESTINATION "Herbert"
    USE_SOURCE_PERMISSIONS
    PATTERN "*.m~" EXCLUDE
    PATTERN "*.asv" EXCLUDE
    PATTERN "*.gitignore" EXCLUDE)
install(FILES "LICENSE" "README.md" DESTINATION ".")
