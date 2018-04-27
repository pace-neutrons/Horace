function [obj,mess]=init_je_(obj,fbMPI,job_control_string)
% initiate the worker parameters
% Inputs:
% job_control_string - the serialized string, contaning information
%                      necessary to initialize the messages framework.
%Output:
% obj    -- Initalized instance of the job executor
% mess   -- empty on success or information about the reason for failure.
%
%

% here we need to know what framework to use
if isfield(job_control_string,'labID') % filebased framework all around
    mf = fbMPI;
else
    if isfield(job_control_struct,'framework_name')
        fr_class_name = job_control_struct.framework_name;
        mf = feval(fr_class_name);
        mf = mf.init_framework(job_control_struct);
    else
        mf = ParpoolMessages(job_control_struct);
    end
end

obj.mess_framework_  = mf;
if fbMPI.labIndex == 1
    numLabs = mf.numLabs;
    all_messages = mf.receive_all(obj,2:numLabs,'started');
    ok = cellfun(@(x)(x.mess_name == 'started'),all_messages,...
        'UniformOutput',true);
    if all(ok)
        [~,mess] = fbMPI.send_message(0,'started');
    else
        fm = aMessage('failed');
        fm.payload = all_messages;
        fbMPI.send_message(0,fm);
        n_failed = sum(~ok);
        mess = sprintf('JobExecutorInit: %d workers falied to start',...
            n_failed);
    end
else
    [~,mess] = mf.send_message(0,'started');
end

