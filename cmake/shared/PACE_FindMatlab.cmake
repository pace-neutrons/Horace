#[=======================================================================[.rst:
PACE_FindMatlab
-----------------

Calls the FindMatlab script that is shipped with CMake, and also finds some
other libraries that are not found by the afformentioned FindMatlab script.

There are some known caching issues with the find step of this module,
particularly if ``Matlab_ROOT_DIR`` and ``Matlab_RELEASE`` have conflicts. If
you run into any issues, please clear the cache and re-configure.

Input Variables to this module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``Matlab_ROOT_DIR``
the path to the root of a Matlab install. If specified this must be consistent
with ``Matlab_RELEASE``, which should also be passed.

``Matlab_RELEASE``
the Matlab release e.g. R2019b you wish to build against.

See the FindMatlab.cmake documentation for other input variables to this
module. You'll find the FindMatlab.cmake script bundled with this repo.

Variables defined by the module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``Matlab_BIN_DIR``
the path to Matlab's bin directory

``Matlab_DLL_DIR`` (Windows only)
the path to the directory containing Matlab's dynamically linked libraries

``Matlab_UT_LIBRARY``
the path to the Matlab UT library

``Matlab_RELEASE``
the Matlab release e.g. R2019b used to build against

See the FindMatlab.cmake documentation for other variables defined by this
module. You'll find the FindMatlab.cmake script bundled with this repo.

#]=======================================================================]
include(PACE_MatlabHelpers)

# Call `find_package(Matlab)` using passed in arguments `Matlab_ROOT_DIR` and/or
# `Matlab_RELEASE` to find the desired version.
matlab_find_package()

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
