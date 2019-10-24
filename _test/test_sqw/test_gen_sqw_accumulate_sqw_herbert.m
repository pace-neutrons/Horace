classdef test_gen_sqw_accumulate_sqw_herbert <  ...
        gen_sqw_accumulate_sqw_tests_common & gen_sqw_common_config
    % Series of tests of gen_sqw and associated functions
    % generated using multiple matlab workers.
    %
    % Optionally writes results to output file to compare with previously
    % saved sample test results
    %---------------------------------------------------------------------
    % Usage:
    %
    %1) Normal usage:
    % Run all unit tests and compare their results with previously saved
    % results stored in test_gen_sqw_accumulate_sqw_output.mat file
    % located in the same folder as this function:
    %
    %>>runtests test_gen_sqw_accumulate_sqw_sep_session
    %---------------------------------------------------------------------
    %2) Run particular test case from the suite:
    %
    %>>tc = test_gen_sqw_accumulate_sqw_sep_session();
    %>>tc.test_[particular_test_name] e.g.:
    %>>tc.test_accumulate_sqw14();
    %or
    %>>tc.test_gen_sqw();
    %---------------------------------------------------------------------
    %3) Generate test file to store test results to compare with them later
    %   (it stores test results into tmp folder.)
    %
    %>>tc=test_gen_sqw_accumulate_sqw_sep_session('save');
    %>>tc.save():
    properties
        worker_h = @worker_4tests
    end
    methods
        function obj=test_gen_sqw_accumulate_sqw_herbert(test_name)
            % Series of tests of gen_sqw and associated functions
            % Optionally writes results to output file
            %
            %   >> test_gen_sqw_accumulate_sqw          % Compares with
            %   previously saved results in
            %   test_gen_sqw_accumulate_sqw_output.mat
            %                                           % in the same
            %                                           folder as this
            %                                           function
            %   >> test_gen_sqw_accumulate_sqw ('save') % Save to
            %   test_multifit_horace_1_output.mat
            %
            % Reads previously created test data sets.
            
            
            if ~exist('test_name','var')
                test_name = mfilename('class');
            end
            obj = obj@gen_sqw_common_config(-1,1,-1,'herbert');
            obj = obj@gen_sqw_accumulate_sqw_tests_common(test_name,'herbert');
        end
        %
        function test_worker(this)
            mis = MPI_State.instance('clear');
            mis.is_tested = true;
            mis.is_deployed = true;
            clot = onCleanup(@()(setattr(mis,'is_deployed',false,'is_tested',false)));
            %
            % Input data:
            %--------------------------------------------------------------
            this= build_test_files(this);
            
            [dummy,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this);
            ds.efix=efix(1);
            ds.emode =emode;
            ds.psi=psi(1);
            ds.omega=omega(1);
            ds.dpsi = dpsi(1);
            ds.gl = gl(1);
            ds.gs = gs(1);
            ds.alatt=alatt;
            ds.angdeg=angdeg;
            ds.u = u;
            ds.v = v;
            
            %
            [path,file] = fileparts(this.spe_file{1});
            tmp_file1 = fullfile(path,[file,'.tmp']);
            run1=rundatah(this.spe_file{1},ds);
            %
            [path,file] = fileparts(this.spe_file{2});
            tmp_file2 = fullfile(path,[file,'.tmp']);
            ds.psi=psi(1);
            run2=rundatah(this.spe_file{1},ds);
            runs = {run1;run2};
            tmp_file = {tmp_file1,tmp_file2};
            clof = onCleanup(@()delete(tmp_file{:}));
            %--------------------------------------------------------------
            % prepare job parameters for the parallel processing
            [common_par,loop_par]=gen_sqw_files_job.pack_job_pars(...
                runs,tmp_file,this.instrum(1),this.sample,...
                [50,50,50,50],[-1.5,-2.1,-0.5,0;0,0,0.5,35]);
            [task_id_list,init_mess]=JobDispatcher.split_tasks(common_par,loop_par,true,1);
            
            serverfbMPI  = MessagesFilebased('test_gen_sqw_worker');
            serverfbMPI.mess_exchange_folder = tempdir;
            clobm = onCleanup(@()finalize_all(serverfbMPI));
            
            starting_mess = serverfbMPI.build_je_init('gen_sqw_files_job',false,false);
            [ok,err]=serverfbMPI.send_message(1,starting_mess);
            assertEqual(ok,MESS_CODES.ok,err);
            
            [ok,err]=serverfbMPI.send_message(1,init_mess{1});
            assertEqual(ok,MESS_CODES.ok,err);
            
            wk_init= serverfbMPI.gen_worker_init(1,1);
            [ok,error_mess]=this.worker_h(wk_init);
            assertTrue(ok,error_mess)
            [ok,err] = serverfbMPI.receive_message(1,'started');
            assertTrue(ok==MESS_CODES.ok,err);
            
            
            assertTrue(exist(tmp_file1,'file')==2);
            assertTrue(exist(tmp_file2,'file')==2);
            [ok,err] = serverfbMPI.receive_message(1,'running');
            assertTrue(ok==MESS_CODES.ok,err);
            
            
            [ok,err,mes] = serverfbMPI.receive_message(1,'completed');
            assertTrue(ok==MESS_CODES.ok,err);
            
            res = mes.payload;
            assertEqual(res.grid_size,[50 50 50 50]);
            assertElementsAlmostEqual(res.urange,...
                [-1.5000 -2.1000 -0.5000 0;0 0 0.5000 35.0000]);
            %
        end
        %
        function test_do_job(this)
            
            mis = MPI_State.instance('clear');
            mis.is_tested = true;
            mis.is_deployed = true;
            clot = onCleanup(@()(setattr(mis,'is_deployed',false,'is_tested',false)));
            
            this= build_test_files(this);
            
            
            [dummy,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this);
            ds.efix=efix(1);
            ds.emode =emode;
            ds.psi=psi(1);
            ds.omega=omega(1);
            ds.dpsi = dpsi(1);
            ds.gl = gl(1);
            ds.gs = gs(1);
            ds.alatt=alatt;
            ds.angdeg=angdeg;
            ds.u = u;
            ds.v = v;
            
            [path,file] = fileparts(this.spe_file{1});
            tmp_file = fullfile(path,[file,'.tmp']);
            clob = onCleanup(@()delete(tmp_file));
            
            run=rundatah(this.spe_file{1},ds);
            
            [common_par,loop_par]=gen_sqw_files_job.pack_job_pars(...
                run,tmp_file,this.instrum(1),this.sample,...
                [50,50,50,50],[-1.5,-2.1,-0.5,0;0,0,0.5,35]);
            
            serverfbMPI  = MessagesFilebased('test_do_job');
            serverfbMPI.mess_exchange_folder = tempdir();
            clob1 = onCleanup(@()finalize_all(serverfbMPI));
            
            
            css1= serverfbMPI.gen_worker_init(1,1);
            % create response filebased framework as would on worker
            control_struct = iMessagesFramework.deserialize_par(css1);
            fbMPI = MessagesFilebased(control_struct);
            
            
            [task_id_list,init_mess]=JobDispatcher.split_tasks(common_par,loop_par,true,1);
            je = gen_sqw_files_job();
            je = je.init(fbMPI,control_struct,init_mess{1});
            
            mis.logger = @(step,n_steps,time,add_info)...
                (je.log_progress(step,n_steps,time,add_info));
            
            
            [ok,err]=serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,err);
            
            je.do_job();
            
            assertTrue(exist(tmp_file,'file')==2);
            [ok,err]=serverfbMPI.receive_message(1,'running');
            assertEqual(ok,MESS_CODES.ok,err);
        end
        %
        function test_finish_task(this)
            
            
            serverfbMPI  = MessagesFilebased('test_finish_task');
            serverfbMPI.mess_exchange_folder = tempdir;
            clob1 = onCleanup(@()finalize_all(serverfbMPI));
            
            
            css1= serverfbMPI.gen_worker_init(1,2);
            css2= serverfbMPI.gen_worker_init(2,2);
            % create response filebased framework as would on worker
            
            
            [task_id_list,init_mess]=JobDispatcher.split_tasks([],2,true,2);
            je = gen_sqw_files_job();
            
            control_struct = iMessagesFramework.deserialize_par(css2);
            fbMPI = MessagesFilebased(control_struct);
            je2 = je.init(fbMPI,control_struct,init_mess{2});
            
            
            control_struct = iMessagesFramework.deserialize_par(css1);
            fbMPI = MessagesFilebased(control_struct);
            je1 = je.init(fbMPI,control_struct,init_mess{1});
            
            [ok,err]=serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,err);
            
            
            grid_size = [50,50,50,50];
            % prepare task outputs as in do_job method
            je1.task_outputs = struct('grid_size',grid_size,...
                'urange',[-1,-2,-3,-20;1,2,3,10]);
            je2.task_outputs = struct('grid_size',grid_size,...
                'urange',[-2,-3,-2,-10;2,3,2,15]);
            je2.finish_task();
            je1.finish_task();
            
            [ok,err,mes]=serverfbMPI.receive_message(1,'completed');
            assertEqual(ok,MESS_CODES.ok,err);
            
            res = mes.payload;
            assertEqual(res.grid_size,[50 50 50 50]);
            assertElementsAlmostEqual(res.urange,...
                [-2,-3, -3,-20; 2, 3, 3 15]);
            
        end
        
        
    end
end
