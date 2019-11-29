function obj = init_framework_(obj,framework_info)
% Internal init_framework method, used to construct functional filebased
% message-exchange framework.
% Input:
%  framework_info -- either:
%             a) string, defining the job name (job_id)
%                 -- or:
%             b) the structure, defined by worker_job_info function:
%                in this case usually defines slave message exchange
%                framework.
%

if exist('framework_info','var')
    if isstruct(framework_info) && isfield(framework_info,'job_id')
        obj.job_id = framework_info.job_id;
    elseif(is_string(framework_info))
        obj.job_id = framework_info;
    else
        error('MPI_MESSAGES:invalid_argument',...
            'inputs for init_framework function does not have correct structure')
    end
else
    error('MPI_MESSAGES:invalid_argument',...
        'inputs for init_framework function is missing')
end
mpi_com_path = which('cpp_communicator');
if isempty(mpi_com_path)
    error('MPI_MESSAGES:runtime_error',...
        'Can not find CPP MPI communicator on Matlab routines search path')
end
try
    ver = cpp_communicator();
    if ~strncmpi(ver,'$Revision::',11)
        error('MPI_MESSAGES:runtime_error',... 
            'Can not probe C++ MPI communicator, returned version %s',...
            ver);
    end
catch Err
    error('MPI_MESSAGES:runtime_error',...
        'Can not initialize MPI communicator, err message: %s',...
        Err.message);    
end

if ~isempty(obj.mpi_framework_holder_)
    cpp_communicator('finalize',obj.mpi_framework_holder_);
end
[obj.mpi_framework_holder_,obj.task_id_,obj.numLabs_]= cpp_communicator('init');




