cmake_minimum_required(VERSION 3.10)

project("Horace")

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
if(NOT CMAKE_MODULE_PATH)
  set(CMAKE_MODULE_PATH)
endif()
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

# Set our options
option(BUILD_TESTS ON)

# Look for packages early so we can exit if they're not found
find_package(OpenMP)
include(horace_FindMatlab)
include(horace_FindHDF5)
if(${BUILD_TESTS})
    include(horace_FindGTest)
    enable_testing()
endif()

# Set the destination of our build artifacts
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

add_subdirectory("_LowLevelCode")
