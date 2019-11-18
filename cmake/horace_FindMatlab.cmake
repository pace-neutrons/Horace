#[=======================================================================[.rst:
horace_FindMatlab
-----------------

Calls the FindMatlab script that is shipped with CMake, and also finds some
other libraries that are not found by the afformentioned FindMatlab script.

Variables defined by the module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``Matlab_UT_LIBRARY``
the path to the Matlab UT library

See the FindMatlab.cmake documentation for other variables defined by this 
module. You'll find the file bundled with your CMake isntallation.

#]=======================================================================]

find_package(Matlab REQUIRED COMPONENTS MAIN_PROGRAM)
get_filename_component(Matlab_LIBRARY_DIR "${Matlab_MEX_LIBRARY}" DIRECTORY)
find_library(Matlab_UT_LIBRARY
    NAMES "ut" "libut"
    HINTS "${Matlab_LIBRARY_DIR}"
    NO_DEFAULT_PATH
)
