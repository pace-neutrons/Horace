function check_mpi_mpiexec_can_be_enabled_(~)
% run couple of dynamical tests verifying that mpiexec communications can
% be established.

if isempty(which('cpp_communicator'))
    mess = 'Can not find cpp_communicator mex file on Matlab search path';
    error('HERBERT:ClusterWrapper:not_available',mess);
end
try
    mex_ver = cpp_communicator();
    if ~is_valid_version(mex_ver)
        error('HERBERT:ClusterMPI:runtime_error',...
            ['Can not reliably probe C++ MPI communicator,'
            ' returned version type: %s is not recognized'],...
            mex_ver);
    end
catch ME
    mess = ME.message;
    error('HERBERT:ClusterWrapper:not_available',mess);
end


mpiexec = ClusterMPI.get_mpiexec();
if ~is_file(mpiexec)
    mess = 'Can not find mpiexec to run parallel programs';
    error('HERBERT:ClusterWrapper:not_available',mess);
end
