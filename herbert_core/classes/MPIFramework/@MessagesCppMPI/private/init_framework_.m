function obj = init_framework_(obj,framework_info)
% Internal init_framework method, used to construct functional CppMPI
% message-exchange framework.
% Input:
%  framework_info -- either:
%   a) string, defining the job name (job_id)
%     -- or:
%   b) the structure, defined by worker_job_info function:
%      in this case usually defines slave message exchange
%      framework.
%      If the string is 'test_mode' or the structure contains the field
%      .test_mode, the framework does not initializes real mpi, but runs
%      sets numLab to one and labNum to 1 and runs as fake worker in the
%      main process flow (not parallel)

test_mode = false;
if exist('framework_info','var')
    if isstruct(framework_info) && isfield(framework_info,'job_id')
        obj.job_id = framework_info.job_id;
        if isfield(framework_info,'test_mode')
            test_mode = true;
        end
    elseif(is_string(framework_info))
        obj.job_id = framework_info;
        if strcmpi(framework_info,'test_mode')
            test_mode = true;
        end
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
            'Can not probe C++ MPI communicator, returned version type: %s is not recognized',...
            ver);
    end
catch Err
    error('MPI_MESSAGES:runtime_error',...
        'Can not initialize MPI communicator, err message: %s',...
        Err.message);
end
obj.data_message_tag_ = MESS_NAMES.mess_id('data');
if ~isempty(obj.mpi_framework_holder_)
    cpp_communicator('finalize',obj.mpi_framework_holder_);
end
if test_mode
    [obj.mpi_framework_holder_,obj.task_id_,obj.numLabs_]= ...
        cpp_communicator('init_test_mode'...
        ,obj.assync_messages_queue_length_,obj.data_message_tag_);
else
    [obj.mpi_framework_holder_,obj.task_id_,obj.numLabs_]= ...
        cpp_communicator('init',...
        obj.assync_messages_queue_length_,obj.data_message_tag_);
end
