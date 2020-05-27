# Copy the required MPI runtimes to herbert_core/DLL
if(UNIX)
    set(MPIEXEC_EXE "glnxa64/mpich-3.3a2/bin/mpiexec")
else()
    set(MPIEXEC_EXE "win64/MSMPI-8.0.12/Bin/mpiexec.exe")
endif()
configure_file("${MPIEXEC_EXE}" "${CMAKE_SOURCE_DIR}/herbert_core/DLL/"
               COPYONLY)
