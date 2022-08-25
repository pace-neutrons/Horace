function [ok, err_mess,je] = parallel_worker(worker_controls_string, ...
    do_logging,do_debugging,do_profiling,do_memory_profiling, ...
    do_html_profiling)
% function used as standard worker to do a job in a separate Matlab
% session.
%
%Inputs:
% worker_controls_string - the structure, containing information, necessary to
%              initiate the job.
%              Due to the fact this string may be transferred
%              through pipes, its size is system dependent and limited, so
%              contains only minimal initialization information, namely the
%              folder name where the job initialization data are located on
%              a remote system.
% do_logging  -- it true, print extensive logging information about the task progress.
% do_debugging-- if true, do not finish parallel worker after task execution
%                in any case. Makes sense only for debugging Herbert
%                framework, to see the results of a task execution on the
%                interactive Matlab session on parallel worker.
%
% Returns:
% ok       -- the task has been successfully completed
% err_mess -- empty if ok==true and contains error message if it is not.
% je       -- instance of a job executor, used to run the particular
%             task after the task completion.

je = [];
ok = false;
%is_tested  = false;
err_mess = 'Failure in the initialization procedure';
if ~exist('do_logging', 'var')
    do_logging = false;
end
if ~exist('do_debugging', 'var')
    do_debugging = false;
end
if ~exist('do_memory_profiling', 'var')
    do_memory_profiling = false;
end
if ~exist('do_profiling', 'var')
    do_profiling = do_memory_profiling;
end
if ~exist('do_html_profiling', 'var')
    do_html_profiling = false;
end
% Check current state of mpi framework and set up deployment status
% within Matlab code to run
mis = MPI_State.instance();
mis.is_deployed = true;
is_tested = mis.is_tested; % set up to tested state within unit tests not to
% exit running Matlab on test failure
% for testing we need to recover 'not-deployed' state to avoid clashes with
% other unit tests. The production job finishes Matlab and clean-up is not necessary
% though doing no harm.
clot = onCleanup(@()(setattr(mis,'is_deployed',false)));
if mis.trace_log_enabled
    fhe = mis.debug_log_handle;
    fwrite(fhe,'at try\n')
end

try


    %% ------------------------------------------------------------------------
    % 1) step 1 of the worker initialization.
    %--------------------------------------------------------------------------
    % There was some issue in testing mpiexec mpi, when this string, provided in command line,
    % was converted into UTF or something similar. Then the failure was occurring,
    % so this command deals with this issue.
    worker_controls_string = char(worker_controls_string);
    if mis.trace_log_enabled
        fwrite(fhe,sprintf('deserializing\n'));
    end
    % Deserialize control string and convert it into a control structure.
    control_struct = iMessagesFramework.deserialize_par(worker_controls_string);
    if mis.trace_log_enabled
        fwrite(fhe,sprintf('deserialized\n'));
    end

    % Initialize config files to use on remote session. Needs to be initialized
    % first as may be used by message framework.

    % Place where config files are stored:
    config_exchange_folder = control_struct.data_path;
    if mis.trace_log_enabled
        fwrite(fhe,sprintf('config exchange folder: %s\n',config_exchange_folder));
        fwrite(fhe,sprintf('job ID: %s\n',control_struct.job_id));
    end

    % set path to the config sources, remove configurations,
    % may be loaded in memory while Horace was initialized.
    config_store.set_config_folder(config_exchange_folder);
    % Initialize the frameworks, responsible for communications within the
    % cluster and between the cluster and the headnode.
    % initiate file-based framework to exchange messages between head node and
    % the pool of workers
    if mis.trace_log_enabled
        fwrite(fhe,sprintf('initializing: %s\n',evalc('disp(control_struct)')));
    end

    [fbMPI,intercomm] = JobExecutor.init_frameworks(control_struct);
    %--------------------------------------------------------------------------
    % step 1 the initialization has been completed providing the
    % communicator for exchange between control node and the cluster and
    % between the clusters nodes. The control node communicator knows the
    % folder for communications
    %--------------------------------------------------------------------------
    if mis.trace_log_enabled
        fwrite(fhe,sprintf('initialized\n'));
    end

    keep_worker_running = true;
    if do_logging
        fh = log_inputs_level1();
        clob_log = onCleanup(@()fclose(fh));
    end
    exit_at_the_end = ~is_tested;
    if do_debugging
        exit_at_the_end = false;
    end
    % inform the control node that the cluster have been started and ready
    % to accept jobs
    if mis.trace_log_enabled
        fwrite(fhe,sprintf('reporting cluster ready\n'));
    end
    JobExecutor.report_cluster_ready(fbMPI,intercomm);
    if mis.trace_log_enabled
        fwrite(fhe,sprintf('cluster ready reported\n'));
    end
catch ME0 %unhandled exception during init procedure
    if mis.trace_log_enabled
        fwrite(fhe,sprintf('unhandled exception at init: %s\n',ME0.identifier));
        fwrite(fhe,sprintf('%s\n',ME0.getReport()));
    end
    ok = false;
    err_mess = ME0;
    if is_tested
        return;
    else
        quit(100);
    end
end

num_of_runs = 0;
while keep_worker_running

    num_of_runs = num_of_runs+1;
    if do_logging; log_num_runs(num_of_runs); end
    fprintf('   *******************************************\n');
    fprintf('   ******  LabN %d  : RUN N : %d  Task: %s *\n',intercomm.labIndex,num_of_runs,fbMPI.job_id);
    fprintf('   *******************************************\n');


    %% --------------------------------------------------------------------
    % 2) step 2 of the worker initialization.
    %----------------------------------------------------------------------

    if do_logging; log_disp_message(' Entering JE loop: receiving "starting" message'); end

    try
        [ok,err,mess]= fbMPI.receive_message(0,'starting','-synch');
        if ok ~= MESS_CODES.ok
            err_mess = sprintf('job N%s failed while receive_je_info Error: %s:',...
                control_struct.job_id,err);
            mess = FailedMessage(err_mess);
            fbMPI.send_message(0,mess);
            ok = MESS_CODES.runtime_error;
            if exit_at_the_end
                quit(254);
            else
                return;
            end
        else
            worker_init_data = mess.payload;
            keep_worker_running = worker_init_data.keep_worker_running;
        end


        exit_at_the_end = ~is_tested && worker_init_data.exit_on_compl;
        if do_debugging
            exit_at_the_end = false; % used for debugging filebased framework, to
            %be able to view the results of a failure.
        end

        if do_logging; log_worker_init_received();  end
        % instantiate job executor class.
        je = feval(worker_init_data.JobExecutorClassName);
        if do_logging; je.ext_log_fh = fh;
        end
        je.do_job_completed = false; % do 2 barriers on exception (one at process failure)
        % ---------------------------------------------------------------------
        % step 2 of the worker initialization completed. a jobExecutor is
        % initialized and worker knows what to do when it finishes or
        % fails.
        %----------------------------------------------------------------------

        %----------------------------------------------------------------------
        % 3) step 3 of the worker initialization. Initializing the particular
        % job executor
        %----------------------------------------------------------------------


        % receive init message which defines the job parameters
        % implicit barrier exists which should block execution until
        % this message is received.
        [ok,err_mess,init_message] = fbMPI.receive_message(0,'init');
        if ok ~= MESS_CODES.ok
            fbMPI.send_message(0,FailedMessage(err_mess));
            if exit_at_the_end
                quit(254);
            else
                return
            end
        end
        if do_logging
            log_init_received();
            log_init_je_started();
        end
        % to decrease probability of other job started their tasks and
        % failed before node 1 is initialized -- let's set this barrier.
        intercomm.labBarrier();
        % node 1 is waiting here until all tasks report "started" to it. If
        % some send failed, it will be unrecoverable failure
        [je,mess] = je.init(fbMPI,intercomm,init_message,is_tested);
    catch ME % JE init have probably not initialized properly or
        % something wrong with the code. We can not process interrupt
        % properly, but filebased framework should still be
        % available.

        if ~strcmp(ME.identifier,'MESSAGE_FRAMEWORK:cancelled')
            % if job is cancelled, we can recover further, as it will throw
            % below at first call to log progress. Any other exception is unhandled one
            if do_logging; log_input_message_exception_caught();  end
            err_mess = sprintf('job "%s" failed. Error during job initialization: %s',...
                control_struct.job_id,ME.message);
            fbMPI.send_message(0,FailedMessage(err_mess,ME));
            ok = false;
            err_mess = ME;
            break;
        end
    end
    %----------------------------------------------------------------------
    try
        if do_logging; log_init_je_finished();  end
        if ~isempty(mess)
            error('WORKER:init_worker',' Error sending ''started'' message from task N%d',...
                fbMPI.labIndex);
        end
        % Successful je.init should return "started" message, initiating
        % blocking receive from all other workers.

        % Attach jobExecutor methods to mpi singleton to be available from any part
        % of the code.
        mis.logger = @(step,n_steps,time,add_info)...
            (je.log_progress(step,n_steps,time,add_info));

        mis.check_cancelled = @()(f_canc(je));


        % send first "running" log message and set-up starting time. Runs
        % asynchronously.
        n_steps = je.n_steps;
        if do_profiling
            if do_memory_profiling
                profile('-memory','on')
            else
                profile('on')
            end
        end
        if do_logging; log_disp_message('Logging start and checking for job cancellation before loop je.is_completed loop\n'); end
        mis.do_logging(0,n_steps);

        % Call initial setup function of JobExecutor
        je = je.setup();
        check_cancellation_status(je, 'before do_job loop');

        while ~je.is_completed()
            je.do_job_completed = false; % do 2 barriers on exception (one at process failure)
            % Execute job (run main job executor's do_job method
            if do_logging; log_disp_message('Entering Je do_job loop'); end

            je= je.do_job();

            % explicitly check for cancellation before data reduction
            if do_logging; log_disp_message('Check for cancellation after Je do_job loop'); end
            check_cancellation_status(je, 'before synchronization after do_job');

            if do_logging; log_disp_message('Got to barrier for all chunks do_job completion'); end
            % when its tested, workers are tested in single Matlab
            % session so it will hand up on synchronization

            % when not tested, the synchronization is mandatory
            je.labBarrier(false); % Wait until all workers finish their
            %                       job before reducing the data
            je.do_job_completed = true; % do 1 barrier on exception at reduction (miss one at process failure)
            if do_logging; log_disp_message('Reduce data started');  end
            % explicitly check for cancellation before data reduction
            %  the case of cancellation below
            check_cancellation_status(je, 'before reducing data');
            je = je.reduce_data();
        end

        % Call final function of JobExecutor
        check_cancellation_status(je, 'after do_job loop');
        je = je.finalise();

        % Sent final running message. Implicitly check for cancellation.
        % The node 1 waits for other nodes to send these this kind of messages
        mis.do_logging(n_steps,n_steps);
        % stop other nodes until the node 1 finishes to produce the
        % final message
        if do_logging; log_disp_message('arriving at JE end of task barrier'); end

        je.labBarrier(false);
        je.do_job_completed = true; % do not wait at barrier if cancellation here

        if do_profiling
            p = profile('info');
            prof_fn = sprintf('Profile_%s_%d_%d_%d',...
                fbMPI.job_id,intercomm.labIndex,intercomm.numLabs,num_of_runs);
            if do_html_profiling
                profsave(p, prof_fn);
            else
                dump_profile(p, prof_fn);
            end
        end

    catch ME % Catch error in users code and finish task gracefully.

        if do_profiling
            profile off
        end

        try
            if do_logging
                log_exception_caught()
                mess = je.process_fail_state(ME,fh);
                log_disp_message(' Completed processing JE fail state');
                log_disp_message('arriving at Process_fail_state end of task barrier')
            else
                mess = je.process_fail_state(ME);
            end

            je.labBarrier(true);
            je.do_job_completed = true;

            if do_logging; log_disp_message('--->Arrived at finish task at failure\n'); end
            if is_tested
                finish_mode = '-asynch';
            else
                finish_mode = '-synch';
            end
            [ok,err_mess,je] = je.finish_task(mess,finish_mode);

            if keep_worker_running
                % migrate job folder for message exchange without deleting the old
                % one
                if do_logging; log_disp_message('--->start migrating log folder\n'); end
                je=je.migrate_job_folder(false);
                continue;
            else
                % useful for testing only
                je=je.migrate_job_folder(false);
                break;
            end
        catch ME1 % the only exception happen is due to error in JE system
            % code. (or user-oveloaded code) Unrecoverable failure
            if do_logging; log_disp_message('************* Error in JE finalize code\n');  end
            err_mess = sprintf('job ID: "%s"; critical failure. JE processing failure error %s:',...
                control_struct.job_id,ME1.message);
            fbMPI.send_message(0,FailedMessage(err_mess,ME1));

            disp(getReport(ME1))
            if exit_at_the_end
                break;
            else
                rethrow(ME1);
            end
        end
    end %Exception

    if do_logging;  fprintf(fh,'************* finishing subtask: %s \n',...
            fbMPI.job_id); end
    [ok,err_mess,je] = je.finish_task();
    % migrate job folder for message exchange without deleting the old
    % one
    je=je.migrate_job_folder(false);

    if do_logging;  fprintf(fh,'************* subtask: %s  finished\n',fbMPI.job_id); end
end
if do_debugging
    disp('************** Paused Parallel worker: Enter something to continue')
    pause % for debugging filebased framework
end

if exit_at_the_end
    quit(0);
end

%% -------------------------------------------------------
% Logging functions used to print debug information
% -------------------------------------------------------
    function log_disp_message(mess)
        fprintf('WORKER_4TESTS: %s ****************************\n',mess);
        fprintf(fh,'---> %s\n',mess);
    end


    function fh = log_inputs_level1()
        log_name = sprintf('Job_%s_wkN%d#%d.log',fbMPI.job_id,intercomm.labIndex,intercomm.numLabs);
        flog_name = fullfile(config_exchange_folder,log_name);
        fh = fopen(flog_name,'w');
        fprintf(fh,'Log file %s :\n',log_name);
        fprintf(fh,'FB MPI settings:\n');
        fprintf(fh,'      Communicator:  : %s:\n',class(fbMPI));
        fprintf(fh,'      Job ID         : %s:\n',fbMPI.job_id);
        fprintf(fh,'      Exchange folder: %s:\n',config_exchange_folder);
        fprintf(fh,'      LabNum         : %d:\n',fbMPI.labIndex);
        fprintf(fh,'      NumLabs        : %d:\n',fbMPI.numLabs);
        fprintf(fh,'Real MPI settings:\n');
        fprintf(fh,'      Communicator:  : %s:\n',class(intercomm));
        fprintf(fh,'      Job ID         : %s:\n',intercomm.job_id);
        fprintf(fh,'      LabNum         : %d:\n',intercomm.labIndex);
        fprintf(fh,'      NumLabs        : %d:\n',intercomm.numLabs);

        % assing logging file-handle to the available frameworks to allow
        % internal logging
        fbMPI.ext_log_fh = fh;
        intercomm.ext_log_fh = fh;
        pool_nodes = intercomm.get_node_names();
        fprintf(fh,'   ***************************************\n');
        fprintf(fh,'Pool visible to node : %s:\n',pool_nodes{intercomm.labIndex});
        for i=1:intercomm.numLabs
            fprintf(fh,'  Node: %d  : Name : %s \n',i,pool_nodes{i});
        end
    end

    function log_num_runs(num_of_runs)
        fprintf(fh,'   ***************************************\n');
        fprintf(fh,'   ******  LabN %d  : RUN N : %d  Task: %s *\n',intercomm.labIndex,num_of_runs,fbMPI.job_id);
        fprintf(fh,'   ****************************************=\n');
    end


    function log_worker_init_received()
        fprintf(fh,['Received starting message with parameters: \n',...
            '         JobExecutor: %s;\n',...
            '         keep_running %d;\n',...
            '         exit lab on completion %d\n'],...
            worker_init_data.JobExecutorClassName,keep_worker_running,exit_at_the_end);
    end

    function log_init_received()
        disp('WORKER_4TESTS: init message received ***********************')
        fprintf(fh,'***************************************\n');
        fprintf(fh,'got JE %s "init" message\n',worker_init_data.JobExecutorClassName);
    end

    function log_init_je_started()
        fprintf(fh,'Trying to start JE: %s\n',worker_init_data.JobExecutorClassName);
        disp('WORKER_4TESTS: initializing worker ************************')
    end

    function log_init_je_finished()
        fprintf(fh,'JE: %s has been initialized, init error message: ''%s''\n',worker_init_data.JobExecutorClassName,mess);
        disp('WORKER_4TESTS: worker has been initialized ************************')
    end

    function log_input_message_exception_caught()
        fprintf(fh,'Receiving Init messages exception caught, ErrMessage: %s, ID: %s;\n',...
            ME.message,ME.identifier);
        ss = numel(ME.stack);
        for i=1:ss
            fprintf(fh,'%s\n',ME.stack(i).file);
            fprintf(fh,'%s\n',ME.stack(i).name);
            fprintf(fh,'%s\n',num2str(ME.stack(i).line));
            fprintf(fh,'%s\n','***************************');
        end
        disp(['WORKER_4TESTS: failing at receiving message: ',ME.identifier])

    end

    function log_exception_caught()
        fprintf(fh,'je exception caught, Message: %s, ID: %s;| job_completed: %d \n',...
            ME.message,ME.identifier,je.do_job_completed);
        ss = numel(ME.stack);
        for i=1:ss
            fprintf(fh,'%s\n',ME.stack(i).file);
            fprintf(fh,'%s\n',ME.stack(i).name);
            fprintf(fh,'%s\n',num2str(ME.stack(i).line));
            fprintf(fh,'%s\n','***************************');
        end
        disp(['WORKER_4TESTS: processing failure: ',ME.identifier])

    end
end

function f_canc(job_executor)

if job_executor.is_job_cancelled()
    error('MESSAGE_FRAMEWORK:cancelled',...
        'Messages framework has been cancelled or is not initialized any more')
end

end

function check_cancellation_status(je, state)
is_cancelled = je.is_job_cancelled();
if is_cancelled
    error('JOB_EXECUTOR:cancelled', 'Job cancelled %s.', state)
end

end
