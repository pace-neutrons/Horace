# Copy the required MPI runtimes to herbert_core/DLL
if(UNIX)
    set(MPIEXEC_EXE "glnxa64/mpich-3.3a2/bin/mpiexec")
    set(LICENSE_FILE "glnxa64/mpich-3.3a2/MPICH-COPYRIGHT")

else()
    set(MPIEXEC_EXE "win64/MSMPI-8.0.12/Bin/mpiexec.exe")
    set(LICENSE_FILE "win64/MSMPI-8.0.12/License/license.rtf")
endif()
configure_file("${MPIEXEC_EXE}" "${Herbert_DLL_DIR}/" COPYONLY)
configure_file("${LICENSE_FILE}" "${Herbert_DLL_DIR}/" COPYONLY)
