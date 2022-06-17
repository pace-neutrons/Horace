set(Horace_DLL_EXTERNAL_DIR "${Horace_ROOT}/_LowLevelCode/external")

# Copy the required MPI runtimes to horace_core/DLL/external
if(UNIX)
    set(Horace_MPICH_DIR "${CMAKE_CURRENT_LIST_DIR}/glnxa64/mpich-3.3a2")
    set(Horace_MPIEXEC_EXE  "${Horace_MPICH_DIR}/bin/mpiexec")
    set(Horace_MPI_LICENSE_FILE "${Horace_MPICH_DIR}/MPICH-COPYRIGHT")
    # MPICH is linked to via shared libraries so these must be copied
    configure_file("${Horace_MPICH_DIR}/lib/libmpi.so.0.0.0"
                   "${Horace_DLL_EXTERNAL_DIR}/libmpi.so.0" COPYONLY)
else()
    set(Horace_MSMPI_DIR "${CMAKE_CURRENT_LIST_DIR}/win64/MSMPI-8.0.12")
    set(Horace_MPIEXEC_EXE
    "${Horace_MSMPI_DIR}/Bin/mpiexec.exe"
    "${Horace_MSMPI_DIR}/Bin/smpd.exe"
    "${Horace_MSMPI_DIR}/Bin/msmpilaunchsvc.exe")
    set(Horace_MPI_LICENSE_FILE "${Horace_MSMPI_DIR}/License/license.rtf")
endif()

foreach(Fl IN ITEMS ${Horace_MPIEXEC_EXE})
    configure_file(${Fl} "${Horace_DLL_EXTERNAL_DIR}/" COPYONLY)
endforeach()


configure_file("${Horace_MPI_LICENSE_FILE}" "${Horace_DLL_EXTERNAL_DIR}/" COPYONLY)
