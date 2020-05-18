classdef test_ParpoolMPI_Framework< MPI_Test_Common
    % Class to test basic mpi method like send/receive/probe message(s)
    %    
    properties
        pool_deleter = [];
    end
    methods
        %
        function this=test_ParpoolMPI_Framework(name)
            if ~exist('name','var')
                name = 'test_ParpoolMPI_Framework';
            end
            this = this@MPI_Test_Common(name);
        end
        function delete(obj)
            obj.pool_deleter = [];
        end
        %
        function test_probe_all_receive_all(obj,varargin)
            % common code -------------------------------------------------
            if obj.ignore_test
                return;
            end
            if nargin>1
                obj.setUp();
                clob0 = onCleanup(@()tearDown(obj));
            end
            
            cl = parcluster();
            num_labs = cl.NumWorkers;
            if num_labs < 3
                warning('Can not run test_send_receive_message, not enough workers');
                return;
            end
            num_labs = 3*floor(num_labs/3);
            if num_labs > 6
                num_labs = 6;
            end
            pl = gcp('nocreate'); % Get the current parallel pool
            %if ~isempty(pl)
            %    delete(pl); %and delete it as job would not run until it stoped
            %end
            % end of    common code ---------------------------------------
            
            %cjob = createCommunicatingJob(cl,'Type','SPMD');
            %cjob.AttachedFiles = {'parpool_mpi_probe_all_tester.m'};
            %cjob.NumWorkersRange  = num_labs;
            %clob1 = onCleanup(@()delete(cjob));
            if isempty(pl) || pl.NumWorkers ~=num_labs
                delete(pl)
                pl = parpool(cl,num_labs);
            end
            if isempty(obj.pool_deleter)
                obj.pool_deleter = onCleanup(@()delete(pl));
            end
            
            num_labs = pl.NumWorkers;
            
            job_param = struct('filepath',obj.working_dir,...
                'filename_template','test_ProbeAllMPI%d_nf%d.txt');
            ind = 1:num_labs;
            job_exchange_folder = job_param.filepath;
            fmt = job_param.filename_template;
            
            fnames = arrayfun(@(ii)(fullfile(job_exchange_folder,sprintf(fmt,ii,num_labs))),...
                ind,'UniformOutput',false);
            clob = onCleanup(@()delete(fnames{:}));
            %task = createTask(cjob,@parpool_mpi_probe_all_tester,2,{job_param});
            %submit(cjob);
            %wait(cjob);
            
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
                assertTrue(exist(fnames{i},'file')==2);
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
                return;
            end
            if nargin>1
                obj.setUp();
                clob0 = onCleanup(@()tearDown(obj));
            end
            
            cl = parcluster();
            num_labs = cl.NumWorkers;
            if num_labs < 3
                warning('Can not run test_send_receive_message, not enough workers');
                return;
            end
            num_labs = 3*floor(num_labs/3);
            if num_labs > 6
                num_labs = 6;
            end
            pl = gcp('nocreate'); % Get the current parallel pool
            %if ~isempty(pl)
            %    delete(pl);
            %end
            if isempty(pl) || pl.NumWorkers ~=num_labs
                delete(pl)
                pl = parpool(cl,num_labs);
            end
            if isempty(obj.pool_deleter)
                obj.pool_deleter = onCleanup(@()delete(pl));
            end
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
                assertTrue(exist(fnames{i},'file')==2);
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
            if obj.ignore_test
                return;
            end
            
            job_param = struct('filepath',obj.working_dir,...
                'filename_template','test_ParpoolMPI%d_nf%d.txt');
            filepath = job_param.filepath;
            fnt = job_param.filename_template;
            fname = sprintf(fnt,1,1);
            file = fullfile(filepath,fname);
            clob = onCleanup(@()delete(file));
            
            mok = parpool_mpi_probe_all_tester(job_param);
            assertTrue(isempty(mok));
            
            assertTrue(exist(file,'file')==2);
        end
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
            assertTrue(exist(file,'file')==2);
            
            %             wrapper = pm.get_mpi_wrapper();
            %             wrapper.set_labIndex(6);
            %             pm = pm.set_mpi_wrapper(wrapper);
            %             mok = parpool_mpi_probe_all_tester(job_param,...
            %                 pm);
            %             assertTrue(mok);
            
        end
        function test_send_receive_tester(obj)
            if obj.ignore_test
                return;
            end
            
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
            
            assertTrue(exist(file,'file')==2);
            
        end
    end
    
end


