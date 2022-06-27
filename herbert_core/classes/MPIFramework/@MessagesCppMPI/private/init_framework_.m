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
if exist('framework_info', 'var')
    if isstruct(framework_info) && isfield(framework_info,'job_id')
        obj.job_id = framework_info.job_id;
        if isfield(framework_info,'test_mode')
            test_mode = true;
        end
        if isfield(framework_info,'labID')
            cluster_range = int32([framework_info.labID,...
                framework_info.numLabs]);
        else
            cluster_range =int32([1,10]);
        end
    elseif(is_string(framework_info))
        obj.job_id = framework_info;
        if strcmpi(framework_info,'test_mode')
            test_mode = true;
            cluster_range =int32([1,10]);
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
    mex_ver = cpp_communicator();
    if ~is_valid_version(mex_ver)
        error('MPI_MESSAGES:runtime_error',...
            'Can not probe C++ MPI communicator, returned version type: %s is not recognized',...
            mex_ver);
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
mis =MPI_State.instance();
if mis.trace_log_enabled
    fh = mis.debug_log_handle;
    fwrite(fh,sprintf('In MessagesCppMPI initialization.\n Test mode %d\n', ...
        test_mode));

end
if test_mode
    [obj.mpi_framework_holder_,obj.task_id_,obj.numLabs_,obj.node_names_ ]= ...
        cpp_communicator('init_test_mode',...
        obj.assync_messages_queue_length_,obj.data_message_tag_,...
        obj.interrupt_chan_tag_,cluster_range);
    obj.is_tested_ = true;
else
    if mis.trace_log_enabled
        inputs = sprintf(['**** Ass_mess_queue_len: %d\n,',...
            '*** data_message_tag: %d;\n*** Interrupt chan tag: %d\n'],...
            obj.assync_messages_queue_length_,obj.data_message_tag_, ...
            obj.interrupt_chan_tag_);
        fwrite(fh,inputs);
    end
    try
        [obj.mpi_framework_holder_,obj.task_id_,obj.numLabs_,obj.node_names_]= ...
            cpp_communicator('init',...
            obj.assync_messages_queue_length_,obj.data_message_tag_,...
            obj.interrupt_chan_tag_);
    catch ME
        if mis.trace_log_enabled
            [mess,mes_id] = lastwarn;
            fwrite(fh,sprintf('last warning %s; mess id %s\n',...
                mess,mes_id));
            fwrite(fh,sprintf('initialization failed\n'));
            fwrite(fh,sprintf('Err:%n %s\n',ME.getReport()));
        end
    end
    if mis.trace_log_enabled
        fwrite(fh,sprintf('initialized\n'));
    end
    obj.is_tested_ = false;
end
obj.task_id_  = double(obj.task_id_);
obj.numLabs_  = double(obj.numLabs_);

