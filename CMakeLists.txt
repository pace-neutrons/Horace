cmake_minimum_required(VERSION 3.7.2)

set(Horace_ROOT ${CMAKE_CURRENT_LIST_DIR})
file(READ "${Horace_ROOT}/VERSION" _version)
string(STRIP "${_version}" _version)
project("Horace" VERSION "${_version}")

# C++11 is required for GTest
set(CMAKE_CXX_STANDARD 11)

# Sort our targets into folders
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# Set CMake policies
if(POLICY CMP0074)
    # Ignore warnings when setting <MODULE>_ROOT variables
    cmake_policy(SET CMP0074 NEW)
endif()

# Add cmake directory to CMake's module path
list(APPEND CMAKE_MODULE_PATH "${Horace_ROOT}/cmake")

# Set some useful global variables
# This will hold herbert/horace_on.m and worker_v2.m
set(LOCAL_INIT_DIR "${CMAKE_BINARY_DIR}/local_init")
# This sets the destination for mex build artefacts (used in PACE_AddMex)
set(Horace_DLL_DIRECTORY "${Horace_ROOT}/horace_core/DLL")
# This is the directory that contains horace_init.m (used in admin/CMakeLists.txt)
set(Horace_CORE "${CMAKE_CURRENT_LIST_DIR}/horace_core")

# Look for packages early so we can exit if they're not found
find_package(Herbert REQUIRED)
find_package(OpenMP)
include(PACE_AddMex)
include(PACE_FindMatlab)
include(horace_FindHDF5)
include(PACE_Version)

# Make analysis ignore Herbert in case of nesting
# Needs to have found herbert for Herbert_ROOT
set(PACE_MLINT_IGNORE ${PACE_MLINT_IGNORE} "${Herbert_ROOT}/**/*.m")

include(PACE_CodeAnalysis)
include(CTest)
if(BUILD_TESTING)
    include(PACE_FindGTest)
    enable_testing()
endif()
include(PACE_Docs)

add_subdirectory("_LowLevelCode")
if(BUILD_TESTING)
    add_subdirectory("_test")
endif()
add_subdirectory("admin")

# =============================================================================
# Install commands
# =============================================================================
include(PACE_CPackConfig)
if(WIN32)
    # Don't package external Linux libraries on Windows
    set(EXTERNAL_IGNORE_PATTERN "*/external/glnxa64")
endif()

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
    DIRECTORY "${Herbert_CORE}/"
    DESTINATION "Herbert"
    USE_SOURCE_PERMISSIONS
    PATTERN "*.m~" EXCLUDE
    PATTERN "*.asv" EXCLUDE
    PATTERN "${EXTERNAL_IGNORE_PATTERN}" EXCLUDE
)
