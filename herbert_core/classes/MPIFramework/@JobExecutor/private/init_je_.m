function [obj,err]=init_je_(obj,fbMPI,intercomm,InitMessage,synchronize)
% initiate the worker parameters
% Inputs:
% fbMPI              - file-based message exchange framework, used for
%                      exchange information between control machine and the
%                      main worker (and distributing initialization
%                      information among workers)
% intercomm          - the class, providing MPI or pseudo MPI communications 
%                      between workers
% InitMessage        - the framework initialization message, containing the
%                      particular job initialization information. 
% synchronize        - if true, use synchronous communications for all
%                      messages, if false, ignore missing messages from
%                      other labs
%Output:
% obj    -- Initialized instance of the job executor
% err    -- empty on success or information about the reason for failure.

%
% just in case of je is reinitialized
obj.do_job_completed = false;
% Store framework, used for message exchange between the head-node and the 
% workers of the cluster.
obj.control_node_exch_ = fbMPI;
% Store framework, used to exchange messages between nodes
obj.mess_framework_   = intercomm;
% Store job parameters
obj.common_data_   = InitMessage.common_data;
obj.n_iterations_  = InitMessage.n_steps;
obj.loop_data_     = InitMessage.loop_data;
obj.return_results_= InitMessage.return_results;
obj.n_first_iteration_= InitMessage.n_first_step;
%
% initialize loggers for messages frameworks to print debug information 
if ~isempty(obj.ext_log_fh) && isnumeric(obj.ext_log_fh)
    fn = fopen(obj.ext_log_fh);
    if ~isempty(fn)
        obj.control_node_exch_.ext_log_fh = obj.ext_log_fh;
        obj.mess_framework_.ext_log_fh = obj.ext_log_fh;
    end
end

% set up message exchange framework to be available in all places of the 
% jobExecutor
mis = MPI_State.instance();
mis.mpi_framework = intercomm;

% inform that job have started.
obj.mess_framework.throw_on_interrupts = true; % if the interrupt received 
%  at this stage, its the problem we can not currently handle properly
[~,err,obj]=obj.reduce_send_message('started','started',[],synchronize);

%

