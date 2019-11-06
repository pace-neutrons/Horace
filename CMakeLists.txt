cmake_minimum_required(VERSION 3.10)

project("Horace")

# Look for packages early so we can exit early
find_package(Matlab REQUIRED COMPONENTS MAIN_PROGRAM)
find_package(OpenMP)

# Set the destination of our build artifacts
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

add_subdirectory("_LowLevelCode")
