classdef test_iMPI_methods< TestCase
    %
    % $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)
    %
    
    properties
        working_dir
        current_config_folder
        current_config
        % handle to the function responsible to run a remote job
        worker_h = @worker_v1;
    end
    methods
        %
        function obj=test_iMPI_methods(name)
            if ~exist('name','var')
                name = 'test_iMPI_methods';
            end
            obj = obj@TestCase(name);
            obj.working_dir = tempdir;
            cs = config_store.instance();
            obj.current_config_folder = cs.config_folder;
            
            pc = parallel_config;
            obj.current_config = pc.get_data_to_store;
        end
        function tearDown(obj)
            % Here we restore the initial configuration as the previous
            % configuration may be restored on remote machine
            cs = config_store.instance();
            cs.set_config_path(obj.current_config_folder);
            pc = parallel_config;
            set(pc,obj.current_config);
        end
        function test_serialize_deserialize(this)
            mf = MFTester('test_ser_deser');
            clob = onCleanup(@()finalize_all(mf));
            wk_floder = 'some_folder';
            job_id = 'some_id';
            css  = mf.build_worker_init(wk_floder,job_id,1,10);
            csr = mf.deserialize_par(css);
            
            sample =  struct('data_path',wk_floder,...
                'job_id',job_id,'labID',1,'numLabs',10);
            assertEqual(sample,csr);
        end
        function test_transfer_init_and_config(obj,varargin)
            if nargin>1
                obj.setUp();
                clob1 = onCleanup(@()tearDown(obj));
            end
            
            % testing the transfer of the initial information for a Herbert
            % job through a data exchange folder
            %
            % Prepare current configuration to be able to restore it after
            % the test finishes
            
            % set up basic default configuration
            pc = parallel_config;
            pc.saveable = false;
            cur_data = pc.get_data_to_store();
            clobC = onCleanup(@()set(pc,cur_data));
            % creates working directory
            pc.working_directory = fullfile(obj.working_dir,'some_irrelevant_folder_never_used_here');
            wkdir0 = pc.working_directory;
            clobW = onCleanup(@()rmdir(wkdir0,'s'));
            
            %--------------------------------------------------------------
            % check the case when local file system and remote file system
            % coincide
            
            pc.shared_folder_on_remote = '';
            pc.shared_folder_on_local = '';
            
            % test structure to send
            % store configuration in a local config folder as local and
            % remote jobs have the same file system
            mpi = iMPITestHelper('testiMPI_transferInit');
            mpi.mess_exchange_folder = obj.working_dir;
            clob0 = onCleanup(@()finalize_all(mpi));
            % the operation above copies config files to the folder
            % calculated by assign operation
            config_exchange = fileparts(fileparts(mpi.mess_exchange_folder));
            assertTrue(exist(fullfile(config_exchange,'herbert_config.mat'),'file')==2);
            
            initMess = mpi.build_je_init('JETester');
            assertTrue(isa(initMess,'aMessage'));
            data = initMess.payload;
            assertTrue(data.exit_on_compl);
            assertFalse(data.keep_worker_running);
            
            % simulate the configuration operations happening on a remote machine side
            mis = MPI_State.instance();
            mis.is_deployed = true;
            mis.is_tested = true;
            clob4 = onCleanup(@()set(mis,'is_deployed',false,'is_tested',false));
            % the filesystem is shared so working_directory is used as
            % shared folder
            wk_dir = fullfile(obj.working_dir,'some_irrelevant_folder_never_used_here');
            assertEqual(pc.working_directory ,wk_dir );
            assertEqual(pc.shared_folder_on_local,wk_dir );
            assertEqual(pc.shared_folder_on_remote,wk_dir );
            
            
            %--------------------------------------------------------------
            %now test storing/restoring project configuration from a
            %directory different from default.
            mis.is_deployed = false;
            pc.shared_folder_on_local = obj.working_dir;
            assertEqual(pc.working_directory ,wk_dir );
            assertEqual(pc.shared_folder_on_local,obj.working_dir);
            assertEqual(pc.shared_folder_on_remote,obj.working_dir);
            
            
            %-------------------------------------------------------------
            % ensure default configuration location will be restored after
            % the test
            clob5 = onCleanup(@()config_store.instance('clear'));
            %
            cfn = config_store.instance().config_folder_name;
            remote_config_folder = fullfile(pc.shared_folder_on_remote,...
                cfn);
            clob6 = onCleanup(@()rmdir(remote_config_folder,'s'));
            % remove all configurations from memory to ensure they would be
            % read from non-default locations.
            config_store.instance('clear');
            
            % these operations would happen on worker
            mis.is_deployed = true;
            config_store.set_config_folder(remote_config_folder)
            
            % on a deployed program working directory coincides with shared_folder_on_remote
            pc = parallel_config;
            assertEqual(pc.working_directory ,pc.shared_folder_on_remote);
            
            
            r_config_folder = config_store.instance().config_folder;
            assertEqual(r_config_folder,remote_config_folder);
            
        end
        function test_mpi_worker_single_thread(obj,varargin)
            if nargin>1
                clob1 = onCleanup(@()tearDown(obj));
            end
            
            
            mis = MPI_State.instance();
            mis.is_tested = true;
            clob3 = onCleanup(@()set(mis,'is_deployed',false,'is_tested',false));
            
            pc = parallel_config;
            pc.saveable = false;
            cur_data = pc.get_data_to_store();
            clobC = onCleanup(@()set(pc,cur_data));
             
            pc.shared_folder_on_local = obj.working_dir;
            
            mpi_comm = MessagesFilebased('test_iMPI_worker');
            mpi_comm.mess_exchange_folder = pc.shared_folder_on_local;
            clob4 = onCleanup(@()finalize_all(mpi_comm));
            
            worker_init = mpi_comm.gen_worker_init(1,1);
            je_initMess     = mpi_comm.build_je_init('JETester');
            
            % JETester specific control parameters
            job_param = struct('filepath',obj.working_dir,...
                'filename_template','test_iMPIMethodsL%d_nf%d.txt');
            jobControlMess = InitMessage(job_param,3,false,1);
            
            mess_exchange_folder = mpi_comm.mess_exchange_folder;
            assertTrue(exist(mess_exchange_folder,'dir') == 7)
            
            
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
            
            assertTrue(exist(created_files{1},'file')==2)
            assertTrue(exist(created_files{2},'file')==2)
            assertTrue(exist(created_files{3},'file')==2)
        end
        
    end
end


