function [obj,err]=init_je_(obj,fbMPI,job_control_string)
% initiate the worker parameters
% Inputs:
% job_control_string - the serialized string, contaning information
%                      necessary to initialize the messages framework.
%Output:
% obj    -- Initalized instance of the job executor
% err    -- empty on success or information about the reason for failure.
%
%

obj.control_node_exch_ = fbMPI;
% here we need to know what framework to use to exchange messages between
% the MPI jobs.
if isfield(job_control_string,'labID') % filebased framework all around
    mf = fbMPI;
else
    if isfield(job_control_struct,'framework_name') % this is for future. Not tried and tested
        fr_class_name = job_control_struct.framework_name;
        mf = feval(fr_class_name);
        mf = mf.init_framework(job_control_struct);
    else
        mf = ParpoolMessages(job_control_struct);
    end
end

obj.mess_framework_  = mf;
[~,err]=obj.reduce_send_message('started');

