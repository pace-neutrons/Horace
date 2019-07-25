function [obj,err]=init_je_(obj,fbMPI,job_control_struct,InitMessage)
% initiate the worker parameters
% Inputs:
% fbMPI              - file-based message exchange framework, used for
%                      exchange intofmation between control machine and the
%                      main worker (and distributing initialization
%                      information among workers)
% job_control_struct - the structure containing information
%                      necessary to initialize the messages framework used
%                      for interaction between workers.
%Output:
% obj    -- Initialized instance of the job executor
% err    -- empty on success or information about the reason for failure.
%
%

obj.control_node_exch_ = fbMPI;
% here we need to know what framework to use to exchange messages between
% the MPI jobs.
if isfield(job_control_struct,'labID') % filebased framework all around
    mf = fbMPI;
else
    if isfield(job_control_struct,'framework_name') % this is for future. Not tried and tested
        fr_class_name = job_control_struct.framework_name;
        mf = feval(fr_class_name);
        mf = mf.init_framework(job_control_struct);
    else % Matlab's parallel-compting toolbox based exchange framework.
        mf = MessagesParpool(job_control_struct);
    end
end
% Store framework, used to exchange messages between nodes
obj.mess_framework_  = mf;
% Store job parameters
obj.common_data_   = InitMessage.common_data;
obj.n_iterations_  = InitMessage.n_steps;
obj.loop_data_     = InitMessage.loop_data;
obj.return_results_= InitMessage.return_results;
obj.n_first_iteration_= InitMessage.n_first_step;
%
[~,err,obj]=obj.reduce_send_message('started',[],true);

