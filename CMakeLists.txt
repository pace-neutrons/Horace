cmake_minimum_required(VERSION 3.7)

project("Herbert" VERSION "3.3.0")

set(CMAKE_CXX_STANDARD 11)

# Sort our targets into folders
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# Set our options
option(BUILD_TESTS "Build the C++ tests" ON)
option(BUILD_FORTRAN "Build the Fortran Mex libraries" OFF)

# Add cmake directory to CMake's path
list(APPEND CMAKE_MODULE_PATH
    "${CMAKE_SOURCE_DIR}/cmake"
    "${CMAKE_SOURCE_DIR}/cmake/external"
)

# Look for packages early so we can exit if they're not found
include(herbert_FindMPI)
include(PACE_FindMatlab)
include(PACE_Version)
include(herbert_AddMex)
if(${BUILD_TESTS})
    include(CTest)
    include(herbert_FindGTest)
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
include(herbert_CPackConfig)

if(WIN32)
    # Don't package external Linux libraries on Windows
    set(EXTERNAL_IGNORE_PATTERN "*/external/glnxa64")
endif()

install(
    DIRECTORY "herbert_core"
    DESTINATION "Herbert"
    USE_SOURCE_PERMISSIONS
    PATTERN "*.m~" EXCLUDE
    PATTERN "*.asv" EXCLUDE
    PATTERN "${EXTERNAL_IGNORE_PATTERN}" EXCLUDE
)
install(
    FILES "LICENSE" "README.md"
    DESTINATION "."
)
