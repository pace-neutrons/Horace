classdef test_ParpoolMPI_Framework< MPI_Test_Common
    % Class to test basic mpi method like send/receive/probe message(s)
    %
    % $Revision$ ($Date$)
    %
    
    properties
    end
    methods
        %
        function this=test_ParpoolMPI_Framework(name)
            if ~exist('name','var')
                name = 'test_ParpoolMPI_Framework';
            end
            this = this@MPI_Test_Common(name);
        end
        %
        function test_probe_all_receive_all(this,varargin)
            % common code -------------------------------------------------
            if this.ignore_test
                return;
            end
            if nargin>1
                this.setUp();
                clob0 = onCleanup(@()tearDown(this));
            end
            
            cl = parcluster();
            num_labs = cl.NumWorkers;
            if num_labs < 3
                return;
            end
            num_labs = 3*floor(num_labs/3);
            if num_labs > 27
                num_labs = 27;
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
            num_labs = pl.NumWorkers;
            
            job_param = struct('filepath',this.working_dir,...
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
        function test_send_receive_message(this,varargin)
            % common code -------------------------------------------------
            if this.ignore_test
                return;
            end
            if nargin>1
                this.setUp();
                clob0 = onCleanup(@()tearDown(this));
            end
            
            cl = parcluster();
            num_labs = cl.NumWorkers;
            if num_labs < 3
                return;
            end
            num_labs = 3*round(num_labs/3);
            if num_labs > 27
                num_labs = 27;
            end
            pl = gcp('nocreate'); % Get the current parallel pool
            %if ~isempty(pl)
            %    delete(pl);
            %end
            if isempty(pl) || pl.NumWorkers ~=num_labs
                delete(pl)
                pl = parpool(cl,num_labs);
            end
            num_labs = pl.NumWorkers;
            
            % end of    common code ---------------------------------------
            
            job_param = struct('filepath',this.working_dir,...
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
        %
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
            
            mok = parpool_mpi_send_receive_tester(job_param);
            assertEqual(mok,-1);
            
            assertTrue(exist(file,'file')==2);
            
        end
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
        
        
        %
        %         function test_labprobe_nonmpi(this)
        %             % The code which runs this is disabled due to the bug in
        %             % parallel parser.
        %             pm = MessagesParpool('nonMPIlogic_tester');
        %             function[isAvail,taskID,tag]=labProbeNonMPI0(task_id)
        %                 isAvailAll = [true,true,false];
        %                 taskIDAll  = [1,2,3];
        %                 tagAll     = [2,3,4];
        %
        %                 isAvail  = isAvailAll(task_id);
        %                 taskID   = taskIDAll(task_id);
        %                 tag      = tagAll(task_id);
        %                 if ~isAvail
        %                     taskID = [];
        %                     tag     = [];
        %                 end
        %             end
        %             [all_messages,task_ids] = pm.probe_all([1,2,3],@labProbeNonMPI0);
        %             assertEqual(numel(all_messages),3);
        %             assertEqual(numel(task_ids),3);
        %             assertTrue(isempty(all_messages{3}));
        %             assertEqual(task_ids(3),0);
        %             assertEqual(MESS_NAMES.mess_id(all_messages{1}),2);
        %             assertEqual(MESS_NAMES.mess_id(all_messages{2}),3);
        %             assertEqual(task_ids(1),1);
        %             assertEqual(task_ids(2),2);
        %
        %             [all_messages,task_ids] = pm.probe_all(3,@labProbeNonMPI0);
        %             assertTrue(isempty(all_messages));
        %             assertEqual(task_ids,0);
        %             %
        %         end
        %
    end
    
end


