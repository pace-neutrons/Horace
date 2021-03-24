classdef test_gen_sqw_accumulate_sqw_herbert <  ...
        gen_sqw_common_config & gen_sqw_accumulate_sqw_tests_common
    % Series of tests of gen_sqw and associated functions
    % generated using multiple Matlab workers.
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
    end
    methods
        function obj=test_gen_sqw_accumulate_sqw_herbert(test_name)
            % Series of tests of gen_sqw and associated functions
            % Optionally writes results to output file
            %
            %   >> test_gen_sqw_accumulate_sqw           % Compares with
            %   previously saved results stored in
            %   test_gen_sqw_accumulate_sqw_output.mat, located
            %   in the same folder as this function.
            %
            %   >> test_gen_sqw_accumulate_sqw ('save')  % Save to
            %   test_multifit_horace_1_output.mat
            %
            % Reads previously created test data sets.


            if ~exist('test_name','var')
                test_name = mfilename('class');
            end
            combine_algorithm = 'mpi_code'; % this is what should be tested
            if is_jenkins && ispc
                combine_algorithm = 'mex_code'; % disable mpi combine on Jenkins. It is extremely slow.
            end
            %
            obj = obj@gen_sqw_common_config(-1,1,combine_algorithm,'herbert');
            obj = obj@gen_sqw_accumulate_sqw_tests_common(test_name,'herbert');
            obj.print_running_tests = true;
        end
        function del_tmp(obj,tmp_files_list)
            for i=1:numel(tmp_files_list)
                file = tmp_files_list{i};
                if exist(file,'file')==2
                    delete(file);
                end
            end
        end

        function test_worker_operations_and_communications(obj)
            % The test verifies the communication protocol between host and
            % remote system running two "remote" sessions with remote workers
            % running the remote job "accumulate_headers" job.
            % The communicatins occur between host and workers and between
            % workers themselves.
            %
            skipTest('Test disabled due to intermittent failure/creation of temp files')
            worker_local = 'parallel_worker';

            mis = MPI_State.instance('clear');
            mis.is_tested = true;
            mis.is_deployed = true;
            clot = onCleanup(@()(setattr(mis,'is_deployed',false,'is_tested',false)));
            %
            % Input data:
            %--------------------------------------------------------------
            obj= build_test_files(obj);

            [dummy,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(obj);
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
            [path,file] = fileparts(obj.spe_file{1});
            tmp_file1 = fullfile(path,[file,'.tmp']);
            run1=rundatah(obj.spe_file{1},ds);
            %
            [path,file] = fileparts(obj.spe_file{2});
            tmp_file2 = fullfile(path,[file,'.tmp']);
            ds.psi=psi(2);
            run2=rundatah(obj.spe_file{1},ds);
            runs = {run1;run2};
            tmp_files = {tmp_file1,tmp_file2};
            clof = onCleanup(@()del_tmp(obj,tmp_files));
            %--------------------------------------------------------------
            % prepare job parameters for the parallel processing
            [common_par,loop_par]=gen_sqw_files_job.pack_job_pars(...
                runs,tmp_files,obj.instrum(1),obj.sample,...
                [50,50,50,50],[-1.5,-2.1,-0.5,0;0,0,0.5,35]);
            [task_id_list,init_mess]=JobDispatcher.split_tasks(common_par,loop_par,true,1);

            serverfbMPI  = MessagesFilebased('test_gen_sqw_worker');
            serverfbMPI.set_framework_range(0,2)
            serverfbMPI.mess_exchange_folder = tmp_dir;
            clobm = onCleanup(@()finalize_all(serverfbMPI));

            starting_mess = JobExecutor.build_worker_init('gen_sqw_files_job',false,false);
            [ok,err]=serverfbMPI.send_message(1,starting_mess);
            assertEqual(ok,MESS_CODES.ok,err);

            [ok,err]=serverfbMPI.send_message(1,init_mess{1});
            assertEqual(ok,MESS_CODES.ok,err);

            wk_init= serverfbMPI.get_worker_init('MessagesFilebased',1,1);

            worker_h = str2func(worker_local);
            [ok,error_mess]=worker_h(wk_init);
            assertTrue(ok,error_mess)
            [ok,err] = serverfbMPI.receive_message(1,'started');
            assertTrue(ok==MESS_CODES.ok,err);


            assertTrue(exist(tmp_file1,'file')==2);
            assertTrue(exist(tmp_file2,'file')==2);
            [ok,err] = serverfbMPI.receive_message(1,'log');
            assertTrue(ok==MESS_CODES.ok,err);


            [ok,err,mes] = serverfbMPI.receive_message(1,'completed');
            assertTrue(ok==MESS_CODES.ok,err);

            res = mes.payload;
            res = res{1};
            assertEqual(res.grid_size,[50 50 50 50]);
            % clear results of gen_tmp job
            serverfbMPI.clear_messages();
            %
            %-------------------------------------------------------------
            % Accumulate headers job. Test components.
            %write_nsqw_to_sqw(infiles,'test_sqw_file.sqw');
            %[main_header,header,datahdr,pos_npixstart,pos_pixstart,npixtot,det,ldrs] = ...
            [~,~,~,~,~,~,det,ldrs] = accumulate_headers_job.read_input_headers(tmp_files);
            %
            pix_range = PixelData.EMPTY_RANGE_;
            for i=1:numel(tmp_files)
                loc_range = ldrs{i}.get_pix_range();
                pix_range = [min(loc_range(1,:),pix_range(1,:));...
                    max(loc_range(2,:),pix_range(2,:))];
            end
            assertElementsAlmostEqual(res.pix_range,pix_range);

            assertEqual(numel(det.group),96);


            [common_par,loop_par] = accumulate_headers_job.pack_job_pars(ldrs);
            assertTrue(isempty(common_par));
            assertEqual(numel(loop_par),2);

            je_init_message = JobExecutor.build_worker_init(...
                'accumulate_headers_job',false,false);
            [task_ids,taskInitMessages]=...
                JobDispatcher.split_tasks(common_par,loop_par,true,2);

            [ok,err]=serverfbMPI.send_message(1,je_init_message);
            assertEqual(ok,MESS_CODES.ok,err);
            [ok,err]=serverfbMPI.send_message(2,je_init_message);
            assertEqual(ok,MESS_CODES.ok,err);
            [ok,err]=serverfbMPI.send_message(1,taskInitMessages{1});
            assertEqual(ok,MESS_CODES.ok,err);
            [ok,err]=serverfbMPI.send_message(2,taskInitMessages{2});
            assertEqual(ok,MESS_CODES.ok,err);

            wk_init1= serverfbMPI.get_worker_init('MessagesFilebased',1,2,false);
            wk_init2= serverfbMPI.get_worker_init('MessagesFilebased',2,2,false);


            [ok,error_mess]=worker_h(wk_init2);
            assertTrue(ok,error_mess)
            [ok,error_mess]=worker_h(wk_init1);
            assertTrue(ok,error_mess)


            [ok,err] = serverfbMPI.receive_message(1,'started');
            assertTrue(ok==MESS_CODES.ok,err);
            [ok,err] = serverfbMPI.receive_message(1,'log');
            assertTrue(ok==MESS_CODES.ok,err);
            [ok,err,mess1] = serverfbMPI.receive_message(1,'completed');
            assertTrue(ok==MESS_CODES.ok,err);
            assertEqual(numel(mess1.payload),2)
            res_s = mess1.payload{1};
            assertEqual(sum(reshape(res_s.npix,1,numel(res_s.npix))),2246);
        end

        function test_do_job(obj)
            skipTest('Test disabled due to intermittent failure  / new SQW loader not available')
            mis = MPI_State.instance('clear');
            mis.is_tested = true;
            mis.is_deployed = true;
            clot = onCleanup(@()(setattr(mis,'is_deployed',false,'is_tested',false)));

            obj= build_test_files(obj);

            [dummy,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(obj);
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

            [path,file] = fileparts(obj.spe_file{1});
            tmp_file = fullfile(path,[file,'.tmp']);
            clob = onCleanup(@()delete(tmp_file));

            run=rundatah(obj.spe_file{1},ds);

            [common_par,loop_par]=gen_sqw_files_job.pack_job_pars(...
                run,tmp_file,obj.instrum(1),obj.sample,...
                [50,50,50,50],[-1.5,-2.1,-0.5,0;0,0,0.5,35]);

            serverfbMPI  = MessagesFilebased('test_do_job');
            serverfbMPI.mess_exchange_folder = tmp_dir();
            clob1 = onCleanup(@()finalize_all(serverfbMPI));


            css1= serverfbMPI.get_worker_init('MessagesFilebased',1,1);
            % create response filebased framework as would on a worker
            control_struct = iMessagesFramework.deserialize_par(css1);
            fbMPI = MessagesFilebased(control_struct);


            [task_id_list,init_mess]=JobDispatcher.split_tasks(common_par,loop_par,true,1);
            je = gen_sqw_files_job();
            je = je.init(fbMPI,fbMPI,init_mess{1});

            mis.logger = @(step,n_steps,time,add_info)...
                (je.log_progress(step,n_steps,time,add_info));


            [ok,err]=serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,err);

            je.do_job();

            assertTrue(exist(tmp_file,'file')==2);
            [ok,err]=serverfbMPI.receive_message(1,'log');
            assertEqual(ok,MESS_CODES.ok,err);


        end

        function test_finish_task(obj)
            skipTest('Test disabled due to intermittent failure')


            serverfbMPI  = MessagesFilebased('test_finish_task');
            serverfbMPI.mess_exchange_folder = tmp_dir;
            clob1 = onCleanup(@()finalize_all(serverfbMPI));


            css1= serverfbMPI.get_worker_init('MessagesFilebases',1,2,false);
            css2= serverfbMPI.get_worker_init('MessagesFilebases',2,2,false);
            % create response filebased framework as would on worker


            [task_id_list,init_mess]=JobDispatcher.split_tasks([],2,true,2);
            je = gen_sqw_files_job();

            control_struct = iMessagesFramework.deserialize_par(css2);
            fbMPI = MessagesFilebased(control_struct);
            je2 = je.init(fbMPI,fbMPI,init_mess{2});


            control_struct = iMessagesFramework.deserialize_par(css1);
            fbMPI = MessagesFilebased(control_struct);
            je1 = je.init(fbMPI,fbMPI,init_mess{1});

            [ok,err]=serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,err);


            grid_size = [50,50,50,50];
            % prepare task outputs as in do_job method
            je1.task_outputs = struct('grid_size',grid_size,...
                'img_range',[-1,-2,-3,-20;1,2,3,10]);
            je2.task_outputs = struct('grid_size',grid_size,...
                'img_range',[-2,-3,-2,-10;2,3,2,15]);
            je2.finish_task();
            je1.finish_task();

            [ok,err,mes]=serverfbMPI.receive_message(1,'completed');
            assertEqual(ok,MESS_CODES.ok,err);

            res = mes.payload;
            res = res{1};
            assertEqual(res.grid_size,[50 50 50 50]);
            assertElementsAlmostEqual(res.img_range,...
                [-1,-2,-3,-20;1,2,3,10]);

        end

        %------------------------------------------------------------------
        % Block of code to disable some tests for debugging Jenkins jobs
        function test_accumulate_and_combine1to4(obj,varargin)
            skipTest('Test disabled due to intermittent failure')
            test_accumulate_and_combine1to4@gen_sqw_accumulate_sqw_tests_common(obj,varargin{:});
        end
        function test_accumulate_sqw1456(obj,varargin)
            skipTest('Test disabled due to intermittent failure')
            test_accumulate_sqw1456@gen_sqw_accumulate_sqw_tests_common(obj,varargin{:});
        end
        function test_accumulate_sqw11456(obj,varargin)
            skipTest('Test disabled due to intermittent failure')
            test_accumulate_sqw11456@gen_sqw_accumulate_sqw_tests_common(obj,varargin{:});
        end
        function test_gen_sqw(obj,varargin)
            skipTest('Test disabled due to intermittent failure')
            test_gen_sqw@gen_sqw_accumulate_sqw_tests_common(obj,varargin{:});
        end
        function test_accumulate_sqw14(obj,varargin)
            skipTest('Test disabled due to intermittent failure')
            test_accumulate_sqw14@gen_sqw_accumulate_sqw_tests_common(obj,varargin{:});
        end

    end
end
