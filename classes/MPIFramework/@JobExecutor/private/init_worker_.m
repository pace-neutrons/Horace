function [obj,argi,job_control_struct,mess]=init_worker_(obj,job_control_string)
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
fr_class_name = job_control_struct.framework_name;

mf = feval(fr_class_name);

mf = mf.init_framework(job_control_struct);
obj.mess_framework_  = mf;

try
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

