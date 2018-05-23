function ok=finish_task_tester(worker_controls_string)
%Inputs:
% worker_controls_string - the structure, containing information, necessary to
%              initiate the job.
%              Due to the fact this string is transferred
%              through pipes its size is system dependent and limited, so
%              contains only minimal initialization information, namely the
%              folder name where the job initialization data are located on
%              a remote system
%
% $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)
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


control_struct = iMessagesFramework.deserialize_par(worker_controls_string);
% Initalize config files to use on remote session. Needs to be initialized
% first as may be used by message framework.
%
% remove configurations, may be loaded in memory while horace was
% initialized.
config_store.instance('clear');
% Where config files are stored:
config_exchange_folder = fullfile(control_struct.data_path,config_store.config_folder_name);
% set pas to config sources:
config_store.set_config_folder(config_exchange_folder);
% instantiate filebasedMessages framework, used to transfer initial data,
% exchange messages between head node and workers pool and display log
% information
fbMPI = MessagesFilebased(control_struct);
% initiate file-based framework to exchange messages between head node and
% the pool of workers
init_message =  InitMessage('dummy_not_user',3,true,1);

je = JETester();
[je,mess] = je.init(fbMPI,control_struct,init_message);
if ~isempty(mess)
    err = sprinft(' Error sending ''started'' message from task N%d',...
        fbMPI.labIndex);
    error('WORKER:init_worker',err);
end
je.task_outputs = sprintf(' finished job for lab %d',labindex());
ok=je.finish_task();
