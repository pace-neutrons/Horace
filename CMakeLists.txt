cmake_minimum_required(VERSION 3.10)

project("Horace")

# Set CMake policies
if(POLICY CMP0074)
    # Ignore warnings when setting <MODULE>_ROOT variables
    cmake_policy(SET CMP0074 NEW)
endif()

# Add cmake directory to CMake's path
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

# Look for packages early so we can exit if they're not found
find_package(OpenMP)
include(horace_FindMatlab)
include(horace_FindHDF5)

# Set the destination of our build artifacts
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

add_subdirectory("_LowLevelCode")
