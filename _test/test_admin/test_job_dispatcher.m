classdef test_job_dispatcher< TestCase
    %
    % $Revision: 278 $ ($Date: 2013-11-01 20:07:58 +0000 (Fri, 01 Nov 2013) $)
    %
    
    properties
        working_dir
    end
    methods
        %
        function this=test_job_dispatcher(name)
            this = this@TestCase(name);
            this.working_dir = tempdir;
        end
        function test_jobs_one_worker(this)
            % JETester specific control parameters
            job_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcherL%d_nf%d.txt');
            
            job_contr = struct('loop_param',[],'n_steps',3,...
                'return_results',false);
            job_contr.loop_param =[job_param,job_param,job_param];
            
            
            file1= fullfile(this.working_dir,'test_jobDispatcherL1_nf1.txt');
            file2= fullfile(this.working_dir,'test_jobDispatcherL1_nf2.txt');
            file3= fullfile(this.working_dir,'test_jobDispatcherL1_nf3.txt');
            files = {file1,file2,file3};
            co = onCleanup(@()(delete(files{:})));
            
            jobs = job_contr;
            jd = JobDispatcher();
            [n_failed,outputs]=jd.send_jobs('JETester',jobs,1,1);
            
            assertEqual(n_failed,0);
            assertTrue(isempty(outputs{1}));
            assertTrue(exist(file1,'file')==2);
            assertTrue(exist(file2,'file')==2);
            assertTrue(exist(file3,'file')==2);
        end
        
        function test_jobs_less_workers(this)
            % JETester specific control parameters
            job_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcherL%d_nf%d.txt');
            
            job_contr = struct('loop_param',[],'n_steps',1,...
                'return_results',true);
            jc1=job_contr;
            jc1.loop_param =[job_param,job_param];
            jc1.n_steps=2;
            jc2=job_contr;
            jc2.loop_param = job_param;
            
            
            file1= fullfile(this.working_dir,'test_jobDispatcherL1_nf1.txt');
            file2= fullfile(this.working_dir,'test_jobDispatcherL1_nf2.txt');
            file3= fullfile(this.working_dir,'test_jobDispatcherL2_nf1.txt');
            files = {file1,file2,file3};
            co = onCleanup(@()(delete(files{:})));
            jobs = [jc1,jc2];
            
            jd = JobDispatcher();
            [n_failed,outputs]=jd.send_jobs('JETester',jobs,2,1);
            assertEqual(n_failed,0);
            assertFalse(isempty(outputs));
            assertEqual(outputs{1},'Job 1 generated 2 files');
            assertEqual(outputs{2},'Job 2 generated 1 files');
            
            assertTrue(exist(file1,'file')==2);
            assertTrue(exist(file2,'file')==2);
            assertTrue(exist(file3,'file')==2);
        end
        
        % tests themself
        function test_jobs(this)
            job_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcher%d_nf%d.txt');
            
            job_contr = struct('loop_param',[],'n_steps',1,...
                'return_results',true);
            job_contr.loop_param =job_param;
            
            
            file1= fullfile(this.working_dir,'test_jobDispatcher1_nf1.txt');
            file2= fullfile(this.working_dir,'test_jobDispatcher2_nf1.txt');
            file3= fullfile(this.working_dir,'test_jobDispatcher3_nf1.txt');
            files = {file1,file2,file3};
            co = onCleanup(@()(delete(files{:})));
            
            jobs = [job_contr,job_contr,job_contr];
            
            jd = JobDispatcher();
            [n_failed,outputs,job_ids]=jd.send_jobs('JETester',jobs,3,1);
            assertEqual(numel(outputs),3);
            assertTrue(all(cellfun(@(x)(~isempty(x)),outputs)));
            assertEqual(numel(job_ids),3);
            assertEqual(outputs{1},'Job 1 generated 1 files')
            
            assertEqual(n_failed,0);
            assertTrue(exist(file1,'file')==2);
            assertTrue(exist(file2,'file')==2);
            assertTrue(exist(file3,'file')==2);
        end
        function test_job_with_logs(this)
            mis = MPI_State.instance();
            mis.is_tested = true;
            mis.is_deployed = true;
            clot = onCleanup(@()(setattr(mis,'is_deployed',false,'is_tested',false)));
            
            
            jd = JDTester('jd_testjob_with_logs_worker');
            clo = onCleanup(@()(jd.clear_all_messages()));
            
            job_par_list = struct('step',0,'n_steps',20);
            
            [jd,job_ids,worker_info] = jd.split_and_register_jobs_pub(job_par_list,2);
            
            assertTrue(iscellstr(worker_info));
            assertEqual(numel(worker_info),1);
            assertTrue(iscell(job_ids))
            assertEqual(numel(job_ids),1);
            assertEqual(numel(job_ids{1}),1);
            
            %
            je = JEwithLogTester();
            [je,job_arguments,err_mess]=je.init_worker(worker_info{1});
            assertTrue(isempty(err_mess));           
            mis.logger = @(step,n_steps,time,addmess)(je.log_progress(step,n_steps,time,addmess));
            
            
            [completed,n_failed,all_changed,jd] = jd.check_jobs_status_pub();
            assertEqual(completed,false);
            assertEqual(n_failed,0);
            assertTrue(all_changed);            
            
            ok = jd.job_state_is(1,'started');
            assertTrue(ok)
            
            je.do_job(job_arguments);
            ok = jd.job_state_is(1,'started');
            assertFalse(ok)
            ok = jd.job_state_is(1,'running');
            assertTrue(ok)
            
            [completed,n_failed,all_changed,jd] = jd.check_jobs_status_pub();
            assertFalse(completed);
            assertEqual(n_failed,0);
            assertTrue(all_changed);            
            ok = jd.job_state_is(1,'running');
            assertFalse(ok)
            
            
            
            
            %assertTrue(isempty(err));
            %step = mess.payload;
            %assertEqual(step,1);
            
        end
        
        %
        function test_job_with_logs_worker(this)
            mis = MPI_State.instance();
            mis.is_tested = true;
            clot = onCleanup(@()(setattr(mis,'is_deployed',false,'is_tested',false)));           
            
            jd = JDTester('jd_testjob_with_logs_worker');
            clo = onCleanup(@()(jd.clear_all_messages()));
            
            job_par_list = struct('step',0,'n_steps',20);
            
            [jd,job_ids,worker_info] = jd.split_and_register_jobs_pub(job_par_list,2);
            
            assertTrue(iscellstr(worker_info));
            assertEqual(numel(worker_info),1);
            assertTrue(iscell(job_ids))
            assertEqual(numel(job_ids),1);
            assertEqual(numel(job_ids{1}),1);
            
            
            ok = jd.job_state_is(1,'starting');
            assertTrue(ok);
            
            worker('JEwithLogTester',worker_info{:});
            
            [ok,err,mess] = jd.receive_message(1,'completed');
            assertTrue(ok)
            assertTrue(isempty(err));
            step = mess.payload;
            assertEqual(step,1);
            
        end
        %
        function test_job_controls_no_running(this)
            %
            job_param_list = {'job_arguments_list_for_worker'};
            
            jd = JDTester('test_job_controls');
            clo = onCleanup(@()(jd.clear_all_messages()));
            
            [jd,job_ids,worker_info] = jd.split_and_register_jobs_pub(job_param_list,1);
            assertTrue(iscellstr(worker_info));
            assertEqual(numel(worker_info),numel(job_ids));
            
            assertTrue(iscell(job_ids))
            assertEqual(numel(job_ids),1);
            assertEqual(numel(job_ids{1}),1);
            
            
            ok = jd.job_state_is(1,'starting');
            assertTrue(ok);
            
            
            je = JETester();
            [je,job_arguments,err_mess]=je.init_worker(worker_info{1});
            assertTrue(isempty(err_mess))
            assertEqual(job_arguments{1},'job_arguments_list_for_worker');
            
            ok = jd.job_state_is(1,'starting');
            assertFalse(ok);
            ok = jd.job_state_is(1,'started');
            assertTrue(ok);
            
            % set up job fail time-out conuter to 3
            tf = jd.time_to_fail;
            jd.jobs_check_time = tf;
            
            % this will never fail -- program will wait for running job
            % indefinetely
            [completed,n_failed,all_changed,jd] = jd.check_jobs_status_pub();
            assertFalse(completed);
            assertEqual(n_failed,0);
            assertTrue(all_changed);            
            [completed,n_failed,all_changed,jd] = jd.check_jobs_status_pub();
            assertFalse(completed);
            assertEqual(n_failed,0);
            assertTrue(all_changed);            
            
            
            % pick up starting message and do not provide anything else
            [ok,err_mess,message]=je.receive_message('started');
            assertTrue(ok);
            assertTrue(isempty(err_mess));
            
            %should fail after three checks
            [completed,n_failed,all_changed,jd] = jd.check_jobs_status_pub();
            assertFalse(completed);
            assertEqual(n_failed,0);
            assertTrue(all_changed);
            
            [~,~,~,jd] = jd.check_jobs_status_pub();
            [completed,n_failed,all_changed,jd] = jd.check_jobs_status_pub();
            assertTrue(completed);
            assertEqual(n_failed,1);
            assertTrue(all_changed);
            
            %
            job_run_info = jd.job_control_structure;
            assertTrue(job_run_info(1).is_failed)
            assertEqual(job_run_info(1).fail_reason,'Timeout waiting for job_completed message');
            
           
           
        end
        %
        function test_split_job_list(this)
            %
            job_param_list = {'aaa','bbbb','s','aaanana'};
            
            jd = JDTester();
            clo = onCleanup(@()(jd.clear_all_messages()));
            
            [jd,job_ids,wc] = jd.split_and_register_jobs_pub(job_param_list,1);
            assertTrue(iscellstr(wc));
            assertEqual(numel(wc),numel(job_ids));
            
            assertTrue(iscell(job_ids))
            assertEqual(numel(job_ids),1);
            assertEqual(numel(job_ids{1}),4);
            
            
            ok = jd.job_state_is(1,'starting');
            assertTrue(ok);
            
            [completed,n_failed,all_changed,jd] = jd.check_jobs_status_pub();
            assertFalse(completed);
            assertEqual(n_failed,0);
            assertFalse(all_changed);
            %-------------------------------------------------------------
            
            job_param_list = {'aaa',[1,2,3,4],'s',10};
            [jd,job_ids,wc] = jd.split_and_register_jobs_pub(job_param_list,2);
            
            assertTrue(iscellstr(wc));
            assertEqual(numel(wc),numel(job_ids));
            
            assertTrue(iscell(job_ids))
            assertEqual(numel(job_ids),2);
            %
            ok = jd.job_state_is(1,'starting');
            assertTrue(ok);
            ok = jd.job_state_is(2,'starting');
            assertTrue(ok);
            
            assertEqual(numel(job_ids{1}),2);
            assertEqual(numel(job_ids{2}),2);
            assertEqual(job_ids{1},[1,2]);
            assertEqual(job_ids{2},[3,4]);
            
            [completed,n_failed,all_changed,jd] = jd.check_jobs_status_pub();
            assertFalse(completed);
            assertEqual(n_failed,0);
            assertFalse(all_changed);           
            %-------------------------------------------------------------
            [jd,job_ids,wc] = jd.split_and_register_jobs_pub(job_param_list,3);
            assertTrue(iscellstr(wc));
            assertEqual(numel(wc),numel(job_ids));
            
            assertTrue(iscell(job_ids))
            assertEqual(numel(job_ids),2);
            
            ok = jd.job_state_is(1,'starting');
            assertTrue(ok);
            ok = jd.job_state_is(2,'starting');
            assertTrue(ok);
            
            assertEqual(numel(job_ids{1}),2);
            assertEqual(numel(job_ids{2}),2);
            assertEqual(job_ids{1},[1,2]);
            assertEqual(job_ids{2},[3,4]);
            
            [completed,n_failed,all_changed,jd] = jd.check_jobs_status_pub();
            assertFalse(completed);
            assertEqual(n_failed,0);
            assertFalse(all_changed);            
            %-------------------------------------------------------------
            
            [jd,job_ids,wc] = jd.split_and_register_jobs_pub(job_param_list,4);
            assertTrue(iscellstr(wc));
            assertEqual(numel(wc),numel(job_ids));
            
            assertTrue(iscell(job_ids))
            assertEqual(numel(job_ids),4);
            
            ok = jd.job_state_is(1,'starting');
            assertTrue(ok);
            ok = jd.job_state_is(2,'starting');
            assertTrue(ok);
            ok = jd.job_state_is(3,'starting');
            assertTrue(ok);
            ok = jd.job_state_is(4,'starting');
            assertTrue(ok);
            
            
            assertEqual(numel(job_ids{1}),1);
            assertEqual(numel(job_ids{2}),1);
            assertEqual(numel(job_ids{3}),1);
            assertEqual(numel(job_ids{4}),1);
            assertEqual(job_ids{1},1);
            assertEqual(job_ids{2},2);
            assertEqual(job_ids{3},3);
            assertEqual(job_ids{4},4);
            
            [completed,n_failed,all_changed,jd] = jd.check_jobs_status_pub();
            assertFalse(completed);
            assertEqual(n_failed,0);
            assertFalse(all_changed);            
            %-------------------------------------------------------------
            [jd,job_ids,wc] = jd.split_and_register_jobs_pub(job_param_list,5);
            assertTrue(iscellstr(wc));
            assertEqual(numel(wc),numel(job_ids));
            
            assertTrue(iscell(job_ids))
            assertEqual(numel(job_ids),4);
            
            ok = jd.job_state_is(1,'starting');
            assertTrue(ok);
            ok = jd.job_state_is(2,'starting');
            assertTrue(ok);
            ok = jd.job_state_is(3,'starting');
            assertTrue(ok);
            ok = jd.job_state_is(4,'starting');
            assertTrue(ok);
            
            
            assertEqual(numel(job_ids{1}),1);
            assertEqual(numel(job_ids{2}),1);
            assertEqual(numel(job_ids{3}),1);
            assertEqual(numel(job_ids{4}),1);
            assertEqual(job_ids{1},1);
            assertEqual(job_ids{2},2);
            assertEqual(job_ids{3},3);
            assertEqual(job_ids{4},4);
            
            [completed,n_failed,all_changed,jd] = jd.check_jobs_status_pub();
            assertFalse(completed);
            assertEqual(n_failed,0);
            assertFalse(all_changed);            
            %-------------------------------------------------------------
            tf = jd.time_to_fail;
            jd.jobs_check_time = tf;
            % this will set time check counter to 2 and we already have one
            % tick. Two ticks more would exceed job fail counter
            [completed,n_failed,all_changed,jd] = jd.check_jobs_status_pub();
            assertFalse(completed);
            assertEqual(n_failed,0);
            assertFalse(all_changed);           
            
            [completed,n_failed,all_changed,jd] = jd.check_jobs_status_pub();
            assertTrue(completed);
            assertEqual(n_failed,4);
            assertTrue(all_changed);
            
            job_run_info = jd.job_control_structure;
            assertTrue(job_run_info(1).is_failed)
            assertEqual(job_run_info(1).fail_reason,'Timeout waiting for job_started message');
            
        end
        
        
    end
end

