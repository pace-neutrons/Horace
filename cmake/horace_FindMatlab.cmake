#[=======================================================================[.rst:
horace_FindMatlab
-----------------

Calls the FindMatlab script that is shipped with CMake, and also finds some
other libraries that are not found by the afformentioned FindMatlab script.

Variables defined by the module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``Matlab_UT_LIBRARY``
the path to the Matlab UT library

``Matlab_DLL_DIR`` (Windows only)
the path to the directory containing Matlab's dynamically linked libraries

See the FindMatlab.cmake documentation for other variables defined by this
module. You'll find the file bundled with your CMake isntallation.

#]=======================================================================]
find_package(Matlab REQUIRED COMPONENTS MAIN_PROGRAM)

# Find the libut library
get_filename_component(Matlab_LIBRARY_DIR "${Matlab_MEX_LIBRARY}" DIRECTORY)
find_library(Matlab_UT_LIBRARY
    NAMES "ut" "libut"
    HINTS "${Matlab_LIBRARY_DIR}"
    NO_DEFAULT_PATH
)
mark_as_advanced(FORCE Matlab_UT_LIBRARY)

# Get the directory containing Matlab's dlls
get_filename_component(_Matlab_BIN_DIR_ "${Matlab_MAIN_PROGRAM}" DIRECTORY)
set(Matlab_BIN_DIR "${_Matlab_BIN_DIR_}" CACHE PATH "Path to Matlab's bin directory" FORCE)
mark_as_advanced(FORCE Matlab_BIN_DIR)
if(WIN32)
    if("CMAKE_SIZEOF_VOID_P" EQUAL 4)
        set(Matlab_DLL_DIR "${Matlab_BIN_DIR}/win32")
    else()
        set(Matlab_DLL_DIR "${Matlab_BIN_DIR}/win64")
    endif()
endif()
