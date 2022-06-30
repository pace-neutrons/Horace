classdef test_iMPI_methods< TestCase
    % Testing the common methods, used by all messages frameworks. 
    % 
    %
    properties
        working_dir
        current_config_folder
        current_config
        % handle to the function responsible to run a remote job
        worker_h = @(str)parallel_worker(str,false);
        % if parallel toolbox is not available or parallel framework is not
        % available, test should be counted as  passed but ignored.
        % Warning is necessary.
    end
    methods
        %
        function obj=test_iMPI_methods(name)
            if ~exist('name', 'var')
                name = 'test_iMPI_methods';
            end
            obj = obj@TestCase(name);
            obj.working_dir = tmp_dir;
            cs = config_store.instance();
            obj.current_config_folder = cs.config_folder;
            
            pc = parallel_config;
            obj.current_config = pc.get_data_to_store;
        end
        %
        function tearDown(obj)
            % Here we restore the initial configuration as the previous
            % configuration may be restored on remote machine
            cs = config_store.instance();
            cs.set_config_path(obj.current_config_folder);
            pc = parallel_config;
            set(pc,obj.current_config);
        end
        %
        function test_add_persistent(~)
            mf = MessagesFilebased();
            
            mf.set_interrupt(FailedMessage('bad faulure'),1);
            mf.set_interrupt(FailedMessage(),10);
            mf.set_interrupt(FailedMessage(),5);
            
            other_mess ={};
            other_id   =[];
            [mess,ids]  = mf.retrieve_interrupt(other_mess,other_id,1:10);
            assertEqual(numel(mess),3);
            assertEqual(numel(ids),3);
            assertEqual(ids,int32([1,5,10]));
            
            other_mess = {'log','data','data','log'};
            other_id = [2,3,4,7];
            [mess,ids]  = mf.retrieve_interrupt(other_mess,other_id,1:10);
            assertEqual(numel(mess),7);
            assertEqual(numel(ids),7);
            assertEqual(ids,int32([1,2,3,4,5,7,10]));
            
            other_id = [1,4,5,7];
            [mess,ids]  = mf.retrieve_interrupt(other_mess,other_id,1:10);
            assertEqual(numel(mess),5);
            assertEqual(numel(ids),5);
            assertEqual(ids,int32([1,4,5,7,10]));
            assertEqual(mess{1},'failed');
            assertEqual(mess{2},'data');
            assertEqual(mess{3},'failed');
            assertEqual(mess{4},'log');
            assertEqual(mess{5},'failed');
        end
        %
        function test_persistent_absent(~)
            mf = MessagesFilebased();
            assertTrue(isempty(mf.get_interrupt(1)));
            
            mf.set_interrupt(LogMessage(),1);
            assertTrue(isempty(mf.get_interrupt(1)));
            
            me = mf.get_interrupt(2);
            assertTrue(isempty(me));
        end
        %
        function test_persistent_present(~)
            mf = MessagesFilebased();
            assertTrue(isempty(mf.get_interrupt(1)));
            
            mf.set_interrupt(FailedMessage('bad faulure'),1);
            me = mf.get_interrupt(1);
            assertTrue(isa(me,'FailedMessage'));
            
            me = mf.get_interrupt(2);
            assertTrue(isempty(me));
            
            [me,id] = mf.get_interrupt('any');
            assertEqual(numel(me),1);
            assertEqual(id,int32(1));
            
            mf.set_interrupt(FailedMessage(),10);
            [me,id] = mf.get_interrupt('any');
            assertEqual(numel(me),2);
            assertEqual(id,int32([1,10]));
            
            mf.set_interrupt(FailedMessage(),4);
            [me,id] = mf.get_interrupt(1:5);
            assertEqual(numel(me),2);
            assertEqual(id,int32([1,4]));
        end
        %
        function test_persistent_get_from_empty(~)
            mf = MessagesFilebased();
            assertTrue(isempty(mf.get_interrupt(1)));
            
            mf.set_interrupt(FailedMessage('bad faulure'),1);
            me = mf.get_interrupt(1);
            assertTrue(isa(me,'FailedMessage'));
            
            [me,id] = mf.get_interrupt([]);
            assertEqual(numel(me),1);
            assertEqual(id,int32(1));
            
            mf.set_interrupt(FailedMessage(),10);
            [me,id] = mf.get_interrupt([]);
            assertEqual(numel(me),2);
            assertEqual(id,int32([1,10]));
            
            mf.set_interrupt(FailedMessage(),4);
            [me,id] = mf.get_interrupt(1:5);
            assertEqual(numel(me),2);
            assertEqual(id,int32([1,4]));
        end
        %
        function test_serialize_deserialize(~)
            mf = MFTester('test_ser_deser');
            clob = onCleanup(@()finalize_all(mf));
            wk_floder = 'some_folder';
            job_id = 'some_id';
            css  = mf.build_worker_init(wk_floder,job_id,'BlaBlaBla',1,10);
            csr = mf.deserialize_par(css);
            
            sample =  struct('data_path',wk_floder,...
                'job_id',job_id,...
                'intercomm_name','BlaBlaBla',...
                'labID',1,'numLabs',10);
            assertEqual(sample,csr);
        end
        %
        function test_mpi_worker_single_thread(obj,varargin)
            if nargin>1
                clob1 = onCleanup(@()tearDown(obj));
            end
            
            
            mis = MPI_State.instance();
            mis.is_tested = true;
            clob3 = onCleanup(@()set(mis,'is_deployed',false,'is_tested',false));
            
            pc = parallel_config;
            pc.saveable = false;
            
            pc.shared_folder_on_local = obj.working_dir;
            
            mpi_comm = MessagesFilebased('test_iMPI_worker');
            mpi_comm.mess_exchange_folder = pc.shared_folder_on_local;
            clob4 = onCleanup(@()finalize_all(mpi_comm));
            
            worker_init = mpi_comm.get_worker_init('MessagesFilebased',1,1);
            jt = JETester();
            je_initMess     = jt.get_worker_init();
            
            % JETester specific control parameters
            job_param = struct('filepath',obj.working_dir,...
                'filename_template','test_iMPIMethodsL%d_nf%d.txt');
            jobControlMess = InitMessage(job_param,3,false,1);
            
            mess_exchange_folder = mpi_comm.mess_exchange_folder;
            assertTrue(is_folder(mess_exchange_folder))
            
            
            mpi_comm.send_message(1,je_initMess);
            mpi_comm.send_message(1,jobControlMess);
            
            
            created_files = {'test_iMPIMethodsL1_nf1.txt',...
                'test_iMPIMethodsL1_nf2.txt','test_iMPIMethodsL1_nf3.txt'};
            created_files = cellfun(@(x)(fullfile(obj.working_dir,x)),...
                created_files,...
                'UniformOutput',false);
            clob5 = onCleanup(@()delete(created_files{:}));
            % initialize worker as if is running on a remote system
            obj.worker_h(worker_init);
            
            assertTrue(is_file(created_files{1}))
            assertTrue(is_file(created_files{2}))
            assertTrue(is_file(created_files{3}))
        end
        
    end
end


