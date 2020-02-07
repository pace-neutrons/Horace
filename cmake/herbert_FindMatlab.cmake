#[=======================================================================[.rst:
herbert_FindMatlab
-----------------

Calls the FindMatlab script that is shipped with CMake, and also finds some
other libraries that are not found by the afformentioned FindMatlab script.

Variables defined by the module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``Matlab_BIN_DIR``
the path to Matlab's bin directory

``Matlab_DLL_DIR`` (Windows only)
the path to the directory containing Matlab's dynamically linked libraries

``Matlab_UT_LIBRARY``
the path to the Matlab UT library

``Matlab_RELEASE``
the Matlab release e.g. R2019b

See the FindMatlab.cmake documentation for other variables defined by this
module. You'll find the file bundled with your CMake installation.

#]=======================================================================]
include(MatlabHelpers)

root_dir_changed(_root_changed)
release_changed(_release_changed)
if(_root_changed AND NOT _release_changed)
    # If Matlab_ROOT_DIR has been changed but not Matlab_RELEASE, discard the
    # old Matlab_RELEASE in favour of the ROOT_DIR
    unset(Matlab_RELEASE CACHE)
elseif(_release_changed AND NOT _root_changed)
    # If Matlab_RELEASE has been changed but not Matlab_ROOT_DIR, discard the
    # old Matlab_ROOT_DIR in favour of the Matlab_RELEASE
    unset(Matlab_ROOT_DIR CACHE)
endif()

if("${Matlab_RELEASE}" STREQUAL "")  # specific version not required
    find_package(Matlab COMPONENTS MAIN_PROGRAM MEX_COMPILER)
else()
    matlab_get_version_from_release_name("${Matlab_RELEASE}" _version)
    find_package(Matlab EXACT ${_version} COMPONENTS MAIN_PROGRAM MEX_COMPILER)
endif()

# Get the release of the Matlab that's been found
matlab_get_release_at_path("${Matlab_ROOT_DIR}" _found_release)

# Set local cached versions of variables so changes on next run can be tracked
set(_CACHED_Matlab_RELEASE "${Matlab_RELEASE}" CACHE INTERNAL "")
set(_CACHED_MATLAB_ROOT_DIR "${Matlab_ROOT_DIR}" CACHE INTERNAL "")

if(${Matlab_FOUND})
    set_matlab_release("${_found_release}")
else()
    set_matlab_release("${_CACHED_Matlab_RELEASE}")
endif()

# Throw error if the Matlab found does not match the Matlab requested by Matlab_RELEASE
if(NOT "${_found_release}" STREQUAL "${Matlab_RELEASE}"
        AND NOT "${_INPUTTED_MATLAB_RELEASE}" STREQUAL "")
    message(FATAL_ERROR
        "Requested Matlab '${_INPUTTED_MATLAB_RELEASE}' doesn't match Matlab "
        "at '${Matlab_ROOT_DIR}'"
    )
endif()

if(NOT ${Matlab_FOUND})
    message(FATAL_ERROR "Matlab '${_CACHED_Matlab_RELEASE}' not found!")
endif()

get_filename_component(Matlab_LIBRARY_DIR "${Matlab_MEX_LIBRARY}" DIRECTORY)
get_filename_component(Matlab_BIN_DIR "${Matlab_MAIN_PROGRAM}" DIRECTORY)

# Find the libut library
find_library(Matlab_UT_LIBRARY
    NAMES "ut" "libut"
    HINTS "${Matlab_LIBRARY_DIR}"
    NO_DEFAULT_PATH
)
mark_as_advanced(FORCE Matlab_UT_LIBRARY)

# The MX library doesn't seem to get found on UNIX, so make sure we have it
if(NOT DEFINED Matlab_MX_LIBRARY)
    find_library(Matlab_MX_LIBRARY
        NAMES "mx" "libmx"
        HINTS "${Matlab_LIBRARY_DIR}"
        NO_DEFAULT_PATH
    )
    mark_as_advanced(FORCE Matlab_MX_LIBRARY)
endif()

# Get the directory containing Matlab's dlls. This is required so we can tell
# CTest to add it to the system path when it runs tests
if(WIN32)
    if("CMAKE_SIZEOF_VOID_P" EQUAL 4)
        set(Matlab_DLL_DIR "${Matlab_BIN_DIR}/win32")
    else()
        set(Matlab_DLL_DIR "${Matlab_BIN_DIR}/win64")
    endif()
endif()
