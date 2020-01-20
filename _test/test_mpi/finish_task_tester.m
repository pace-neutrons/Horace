function ok=finish_task_tester(worker_controls_string,varargin)
% The routine used in unit tests to reproduce part of the worker
% operations, namely initialization and completeon.
%Inputs:
% worker_controls_string - the structure, containing information, necessary to
%              initiate the job.
%              Due to the fact this string is transferred
%              through pipes its size is system dependent and limited, so
%              contains only minimal initialization information, namely the
%              folder name where the job initialization data are located on
%              a remote system
% varargin(n-neighbour) -- if present, defines number of "virtual"
%             neighboring workers, used as sources of messages to
%             test cpp_mpi communications.
%
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
%

if isempty(which('herbert_init.m'))
    horace_on();
end
% Check current state of mpi framework and set up deployment status
% within Matlab code to run
mis = MPI_State.instance();
mis.is_deployed = true;
%
% for testing we need to recover 'not-deployed' state to avoid clashes with
% other unit tests. The production job finishes Matlab and clean-up is not necessary
% though doing no harm.
clot = onCleanup(@()(setattr(mis,'is_deployed',false)));
me = mess_cache.instance();
clob = onCleanup(@()delete(me));

control_struct = iMessagesFramework.deserialize_par(worker_controls_string);
% Initialize config files to use on remote session. Needs to be initialized
% first as may be used by message framework.
%
% remove configurations, may be loaded in memory while Horace was
% initialized.
config_store.instance('clear');
% Where config files are stored:
cfn = config_store.instance().config_folder_name;
config_exchange_folder = fullfile(control_struct.data_path,cfn);
% set pas to config sources:
config_store.set_config_folder(config_exchange_folder);
% Initialize the frameworks, responsible for communications within the
% cluster and between the cluster and the headnode.
[fbMPI,intercomm] = JobExecutor.init_frameworks(control_struct);
if nargin>1
    % simulate fake extra nodes who started in parallel with this one and
    % reporting "started" state
    for i=2:varargin{1}
        intercomm.send_message(i,'started');
    end
end
try
    % initiate file-based framework to exchange messages between head node and
    % the pool of workers
    init_message =  InitMessage('dummy_not_used',3,true,1);
    
    je = JETester();
    [je,mess] = je.init(fbMPI,intercomm,init_message);
    labind = intercomm.labIndex();
    %
    if ~isempty(mess)
        disp([' non-empty message for lab ',num2str(labind)])
        err = sprinft(' Error sending ''started'' message from task N%d',...
            fbMPI.labIndex);
        error('WORKER:init_worker',err);
    end
    je.task_outputs = sprintf(' finished job for lab %d',je.labIndex);
    %
    if nargin>1
        % simulate fake extra nodes who completed before this one
        % and are reporting "completed" state
        for i=2:varargin{1}
            intercomm.send_message(i,'completed');
        end
    end
    ok=je.finish_task();
catch ME
    intercomm.clear_messages();
    rethrow(ME);
end

