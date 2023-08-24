classdef test_ParpoolMPI_Framework< MPI_Test_Common
    % Class to test basic mpi method like send/receive/probe message(s)
    %
    properties
        pool_deleter = [];
        pool
        cluster
        n_max_workers = 6
    end
    methods
        %
        function obj=test_ParpoolMPI_Framework(name)
            if ~exist('name', 'var')
                name = 'test_ParpoolMPI_Framework';
            end
            obj = obj@MPI_Test_Common(name);
            %
            avail = license('checkout', 'Distrib_Computing_Toolbox');
            if ~avail
                obj.ignore_test = true;
                return;
            end

        end
        function pl = start_pool(obj)
            cl = parcluster();
            num_labs = cl.NumWorkers;
            if num_labs < 3
                warning('May not be possible to run parpool tests, not enough workers');
                %obj.ignore_test = true;
                %pl = [];
                %return;
                obj.n_max_workers = 3;
                num_labs = 3;
                cl.NumWorkers = 3;
            end
            num_labs = 3*floor(num_labs/3);
            if num_labs > obj.n_max_workers
                num_labs = obj.n_max_workers;
            end

            pl = gcp('nocreate'); % Get the current parallel pool
            %if ~isempty(pl)
            %    delete(pl);
            %end
            if isempty(pl) || pl.NumWorkers ~=num_labs
                obj.cluster = cl;
                delete(pl)
                obj.pool_deleter = [];
                pl = parpool(cl,num_labs);
                obj.pool_deleter = onCleanup(@()delete(pl));
                obj.pool = pl;
            else
                obj.pool = pl;
            end

        end
        function delete(obj)
            obj.pool_deleter = [];
        end
        %
        function test_finish_tasks_reduce_messages(obj,varargin)
            if is_jenkins() && ispc() && (matlab_version_num()==9.05)
                skipTest('Test ignored due to instability on Windows Jenkins');
            end
            if obj.ignore_test
                skipTest(obj.ignore_cause);
            end

            pl = obj.start_pool();
            assertFalse(isempty(pl),'problem getting access to parallel pool')

            serverfbMPI  = MessagesFilebased('test_finish_tasks_reduce_mess');
            serverfbMPI.mess_exchange_folder = obj.working_dir;

            clob = onCleanup(@()finalize_all(serverfbMPI));
            % generate 3 controls to have 3 filebased MPI pseudo-workers
            css1= serverfbMPI.get_worker_init('MessagesParpool');

            num_labs = pl.NumWorkers;
            spmd
                ok = finish_task_tester(css1);
            end


            assertEqual(numel(ok),num_labs);
            all_ok = arrayfun(@(x)(x{1}),ok,'UniformOutput',true);
            assertTrue(all(all_ok));
            [ok,err,mess] = serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,err);
            assertTrue(isa(mess,'aMessage'));
            assertEqual(mess.mess_name,'started');
            [ok,err,mess] = serverfbMPI.receive_message(1,'completed');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'completed');

        end
        %
        function test_probe_all_receive_all(obj,varargin)
            % common code -------------------------------------------------
            if obj.ignore_test
                skipTest(obj.ignore_cause);
            end

            pl = obj.start_pool();
            assertFalse(isempty(pl),'problem getting access to parallel pool')

            num_labs = pl.NumWorkers;


            job_param = struct('filepath',obj.working_dir,...
                'filename_template','test_ProbeAllMPI%d_nf%d.txt');
            ind = 1:num_labs;
            job_exchange_folder = job_param.filepath;
            fmt = job_param.filename_template;

            fnames = arrayfun(@(ii)(fullfile(job_exchange_folder,sprintf(fmt,ii,num_labs))),...
                ind,'UniformOutput',false);
            clob = onCleanup(@()delete(fnames{:}));
            spmd
                [res,err] = parpool_mpi_probe_all_tester(job_param);
            end
            %results = fetchOutputs(cjob);
            %res = results(:,1);
            %err = results(:,2);
            assertTrue(isempty([err{:}]));

            lab_ids = 1:num_labs;
            receivers = rem(lab_ids,3)==0;
            received = res(receivers);
            n_sent = cellfun(@numel,received);
            assertTrue(all(n_sent==2));

            for i=1:num_labs
                assertTrue(is_file(fnames{i}));
                if (receivers(i))
                    res_rez=res{i};
                    mis_mes = arrayfun(@(x)isempty(x.mess),res_rez);
                    assertFalse(any(mis_mes))
                else
                    assertTrue(res{i});
                end
            end

        end
        %
        function test_send_receive_message(obj,varargin)
            % common code -------------------------------------------------
            if obj.ignore_test
                skipTest(obj.ignore_cause);
            end

            pl = obj.start_pool();
            assertFalse(isempty(pl),'problem getting access to parallel pool')

            num_labs = pl.NumWorkers;
            % end of    common code ---------------------------------------

            job_param = struct('filepath',obj.working_dir,...
                'filename_template','test_ParpoolMPI%d_nf%d.txt');

            ind = 1:num_labs;
            %cjob = createCommunicatingJob(cl,'Type','SPMD');
            %cjob.AttachedFiles = {'parpool_mpi_send_receive_tester.m'};
            %cjob.NumWorkersRange  = num_labs;

            job_exchange_folder = job_param.filepath;
            fmt = job_param.filename_template;

            fnames = arrayfun(@(ii)(fullfile(job_exchange_folder,sprintf(fmt,ii,num_labs))),...
                ind,'UniformOutput',false);
            clob = onCleanup(@()delete(fnames{:}));
            %
            % -- non-interactive working code
            %task = createTask(cjob,@parpool_mpi_send_receive_tester,2,{job_param});
            %submit(cjob);
            %wait(cjob);
            %clob1 = onCleanup(@()delete(cjob));

            spmd
                [res,err] = parpool_mpi_send_receive_tester(job_param);
            end

            %results = fetchOutputs(cjob);
            %res = results(:,1);
            %err = results(:,2);

            for i=1:num_labs
                assertTrue(is_file(fnames{i}));
                assertTrue(isempty(err{i}));
                assertTrue(isa(res{i},'aMessage'));
                cii = i-1; % cyclic backward index used by worker to send messages and define their payload.
                if cii<1; cii= cii+num_labs;  end
                mess = res{i};
                assertEqual(mess.mess_name,'started');
                assertEqual(mess.payload,cii*10);
            end

        end
        %
        function test_probe_receive_all_tester(obj)


            job_param = struct('filepath',obj.working_dir,...
                'filename_template','test_ParpoolMPI%d_nf%d.txt');
            filepath = job_param.filepath;
            fnt = job_param.filename_template;
            fname = sprintf(fnt,1,1);
            file = fullfile(filepath,fname);
            clob = onCleanup(@()delete(file));

            mok = parpool_mpi_probe_all_tester(job_param);
            assertTrue(isempty(mok));

            assertTrue(is_file(file));
        end
        %
        function test_probe_receive_all_tester_test_mode(obj)

            job_param = struct('filepath',obj.working_dir,...
                'filename_template','test_ParpoolMPI%d_nf%d.txt');
            filepath = job_param.filepath;
            fnt = job_param.filename_template;
            fname = sprintf(fnt,1,6);
            file = fullfile(filepath,fname);
            clob = onCleanup(@()delete(file));

            [mok,~,pm] = parpool_mpi_probe_all_tester(job_param,...
                struct('job_id','test_probe_all','labID',1,'numLabs',6));
            assertTrue(mok);
            assertTrue(is_file(file));

            %             wrapper = pm.get_mpi_wrapper();
            %             wrapper.set_labIndex(6);
            %             pm = pm.set_mpi_wrapper(wrapper);
            %             mok = parpool_mpi_probe_all_tester(job_param,...
            %                 pm);
            %             assertTrue(mok);

        end
        %
        function test_send_receive_tester(obj)

            job_param = struct('filepath',obj.working_dir,...
                'filename_template','test_ParpoolMPI%d_nf%d.txt');
            filepath = job_param.filepath;
            fnt = job_param.filename_template;
            fname = sprintf(fnt,1,1);
            file = fullfile(filepath,fname);
            clob = onCleanup(@()delete(file));
            pool_control = struct('job_id',...
                'parpool_MPI_tester','labID',1,'numLabs',1);
            mok = parpool_mpi_send_receive_tester(job_param,pool_control );
            assertTrue(isa(mok,'aMessage'));
            assertEqual(mok.mess_name,'started');

            assertTrue(is_file(file));

        end
    end

end
