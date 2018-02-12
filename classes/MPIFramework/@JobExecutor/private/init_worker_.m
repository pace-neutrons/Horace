function [obj,argi,mess]=init_worker_(obj,job_control_string)
% initiate the worker parameters
% Inputs:
% job_control_string - the serialized string, contaning information
%                      necessary to initialize the messages framework.
%Output:
% obj    -- Initalized instance of the job executor
% argi   -- the reecived input for the do_job method.
% mess   -- empty on success or information about the reason for failure.
%
%
argi = [];
try
    job_control_struct = iMessagesFramework.deserialize_par(job_control_string);
catch ME
    mess = ME.message;
    return
end
% here we need to know what framework to use
try
    conf = hpc_config;
    
    mf = conf.messages_framework;
catch
    mf = FilebasedMessages;
    warning('hpc config has not yet been implemented')
end
mf = mf.init_framework(job_control_struct);
obj.mess_framework_  = mf;

try
    % TODO: HACK! this is filebased worker, which is initated by mpi_info only
    obj.task_id_        = job_control_struct.mpi_info;
    %
    [ok,mess,message] = obj.receive_message('starting');
    if ok
        argi = message.payload;
    else
        return
    end
catch ME
    mess = ME.message;
    return;
end
[~,mess] = obj.send_message('started');

