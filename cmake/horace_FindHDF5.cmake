#[=======================================================================[.rst:
horace_FindHDF5
-----------------

Find the HDF5 library that is contained within this repository.

Variables defined by the module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

See the FindHDF5.cmake documentation for other variables defined by this
module. You'll find the file bundled with your CMake isntallation.

#]=======================================================================]
if(UNIX)
    set(HDF5_ROOT "${CMAKE_SOURCE_DIR}/_LowLevelCode/external/HDF5_1.8.12_unix/")
    # On Linux, link to Matlab's version of HDF5
    set(HDF5_hdf5_LIBRARY_RELEASE "${Matlab_LIBRARY_DIR}/libhdf5.so.8"
        CACHE PATH "" FORCE)
elseif(WIN32)
    set(HDF5_ROOT "${CMAKE_SOURCE_DIR}/_LowLevelCode/external/HDF5_1.8.12_win/")
endif()
find_package(HDF5)
