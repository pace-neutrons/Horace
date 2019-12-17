function check_mpi_mpiexec_can_be_enabled_(obj)


if isempty(which('cpp_communicator'))
    mess = 'Can not find cpp_communicator mex file on Matlab search path';
    error('PARALLEL_CONFIG:not_available',mess);
end
try
    ver = cpp_communicator();
catch ME
    mess = ME.message;
    error('PARALLEL_CONFIG:not_available',mess);
end


mpiexec = ClusterMPI.get_mpiexec();
if ~exist(mpiexec,'file')==2
    mess = 'Can not find mpiexec to run parallel programs';
    error('PARALLEL_CONFIG:not_available',mess);
end
