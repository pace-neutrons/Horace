set(Herbert_DLL_EXTERNAL_DIR "${Herbert_DLL_DIR}/external")

# Copy the required MPI runtimes to herbert_core/DLL/external
if(UNIX)
    set(Herbert_MPICH_DIR "${CMAKE_CURRENT_LIST_DIR}/glnxa64/mpich-3.3a2")
    set(Herbert_MPIEXEC_EXE "${Herbert_MPICH_DIR}/bin/mpiexec")
    set(Herbert_MPI_LICENSE_FILE "${Herbert_MPICH_DIR}/MPICH-COPYRIGHT")
    # MPICH is linked to via shared libraries so these must be copied
    configure_file("${Herbert_MPICH_DIR}/lib/libmpi.so.0.0.0"
                   "${Herbert_DLL_EXTERNAL_DIR}/libmpi.so.0" COPYONLY)
else()
    set(Herbert_MSMPI_DIR "${CMAKE_CURRENT_LIST_DIR}/win64/MSMPI-8.0.12")
    set(Herbert_MPIEXEC_EXE "${Herbert_MSMPI_DIR}/Bin/mpiexec.exe")
    set(Herbert_MPIEXEC_EXE "${Herbert_MSMPI_DIR}/Bin/smpd.exe")
    set(Herbert_MPIEXEC_EXE "${Herbert_MSMPI_DIR}/Bin/msmpilaunchsvc.exe")
    set(Herbert_MPI_LICENSE_FILE "${Herbert_MSMPI_DIR}/License/license.rtf")
endif()

configure_file("${Herbert_MPIEXEC_EXE}" "${Herbert_DLL_EXTERNAL_DIR}/" COPYONLY)
configure_file("${Herbert_MPI_LICENSE_FILE}" "${Herbert_DLL_EXTERNAL_DIR}/" COPYONLY)
