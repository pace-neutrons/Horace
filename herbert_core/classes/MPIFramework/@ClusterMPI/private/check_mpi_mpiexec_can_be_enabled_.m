function check_mpi_mpiexec_can_be_enabled_(obj)
% run couple of dynamical tests verifying that mpiexec communications can
% be established.

if isempty(which('cpp_communicator'))
    mess = 'Can not find cpp_communicator mex file on Matlab search path';
    error('PARALLEL_CONFIG:not_available',mess);
end
try
    ver = cpp_communicator();
    if ~strncmpi(ver,'$Revision::',11)
        error('PARALLEL_CONFIG:runtime_error',...
            ['Can not reliably probe C++ MPI communicator,'
            ' returned version type: %s is not recognized'],...
            ver);
    end
catch ME
    mess = ME.message;
    error('PARALLEL_CONFIG:not_available',mess);
end


mpiexec = ClusterMPI.get_mpiexec();
if ~exist(mpiexec,'file')==2
    mess = 'Can not find mpiexec to run parallel programs';
    error('PARALLEL_CONFIG:not_available',mess);
end
