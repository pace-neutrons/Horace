cmake_minimum_required(VERSION 3.7)

project("Horace" VERSION "3.3.0")

# C++11 is required for GTest
set(CMAKE_CXX_STANDARD 11)

# Sort our targets into folders
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# Set CMake policies
if(POLICY CMP0074)
    # Ignore warnings when setting <MODULE>_ROOT variables
    cmake_policy(SET CMP0074 NEW)
endif()

# Add cmake directory to CMake's path
list(APPEND CMAKE_MODULE_PATH
    "${CMAKE_SOURCE_DIR}/cmake"
    "${CMAKE_SOURCE_DIR}/cmake/external"
)

# Set some useful global variables
# this will hold herbert/horace_on.m and worker_v2.m
set(LOCAL_INIT_DIR "${CMAKE_BINARY_DIR}/local_init")

# Set our options
option(BUILD_TESTS "Build the C++ tests" ON)

# Look for packages early so we can exit if they're not found
find_package(Herbert REQUIRED)
find_package(OpenMP)
include(PACE_AddMex)
include(PACE_FindMatlab)
include(horace_FindHDF5)
include(PACE_Version)
if(${BUILD_TESTS})
    include(CTest)
    include(PACE_FindGTest)
    enable_testing()
endif()

# Set the destination of our build artifacts
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

add_subdirectory("_LowLevelCode")
if(${BUILD_TESTS})
    add_subdirectory("_test")
endif()
add_subdirectory("admin")

# =============================================================================
# Install commands
# =============================================================================
include(PACE_CPackConfig)

install(
    DIRECTORY "horace_core/"
    DESTINATION "Horace"
    USE_SOURCE_PERMISSIONS
    PATTERN "*.m~" EXCLUDE
    PATTERN "*.asv" EXCLUDE
)
install(
    FILES "LICENSE" "README.md"
    DESTINATION "."
)
install(
    DIRECTORY "${Herbert_ROOT}/"
    DESTINATION "Herbert"
    USE_SOURCE_PERMISSIONS
    PATTERN "*.m~" EXCLUDE
    PATTERN "*.asv" EXCLUDE
)
