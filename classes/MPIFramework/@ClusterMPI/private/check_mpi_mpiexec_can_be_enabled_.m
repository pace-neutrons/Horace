function check_mpi_mpiexec_can_be_enabled_(obj)

ok = true;
mess = [];
if isempty('cpp_communicator')
    ok = false;
    mess = 'Can not find cpp_communicator mex file on Matlab search path';
end

mpiexec = ClusterMPI.get_mpiexec();
if ~exist(mpiexec,'file')==2
    ok = false;
    mess = 'Can not find mpiexec to run parallel programs';
end

if ~ok
    error('PARALLEL_CONFIG:not_available',mess);
end