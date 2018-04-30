classdef test_iMPI_methods< TestCase
    %
    % $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)
    %
    
    properties
        working_dir
        current_config_folder
        current_config
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
            css = mf.worker_job_info('SomeWorker',3);
            dat = mf.serialize_par(css);
            
            csr = mf.deserialize_par(dat);
            assertEqual(css,csr);
        end
        function test_transfer_init_and_config(obj,varargin)
            
            if nargin>1
                clob1 = onCleanup(@()tearDown(obj));
            end
            
            % testing the transfer of the initial information for a Herbert
            % job through a data exchange folder
            %
            % Prepare current configuration to be able to restore it after
            % the test finishes
            
            % set up basic default configuration
            pc = parallel_config;
            
            pc.working_directory = 'some_irrelevant_folder_never_used_here';
            pc.shared_folder_on_remote = '';
            pc.shared_folder_on_local = '';
            %--------------------------------------------------------------
            % check the case when local file system and remote file system
            % coinside
            % test structure to send
            data_struct = struct('some_field',1,'other_field','bbbb');
            
            
            % store configuration in a local config folder as local and
            % remote jobs have the same file system
            mpi = iMPITestHelper();
            mpi.send_job_info(data_struct);
            
            % simulate the configuration operations happening on a remote macine side
            mis = MPI_State.instance();
            mis.is_deployed = true;
            mis.is_tested = true;
            clob4 = onCleanup(@()set(mis,'is_deployed',false,'is_tested',false));
            % the filesystem is share so working_directory is used as
            % shared folder
            assertEqual(pc.working_directory ,'some_irrelevant_folder_never_used_here');
            assertEqual(pc.shared_folder_on_local,'some_irrelevant_folder_never_used_here');
            assertEqual(pc.shared_folder_on_remote,'some_irrelevant_folder_never_used_here');
            
            % configuraton is retrieved from the local configuration
            [filename,filepath] = mpi.par_config_file();
            info_file = fullfile(filepath,filename);
            clob3 = onCleanup(@()delete(info_file));
            assertEqual(exist(info_file,'file'),2);
            
            [rest_info,config_f] = mpi.receive_job_info(obj.current_config_folder,'-keep');
            assertEqual(data_struct,rest_info);
            assertEqual(config_f,fullfile(obj.current_config_folder,mpi.exchange_folder_name))
            %--------------------------------------------------------------
            %now test storing/restoring project configuration from a
            %directory different from default.
            mis.is_deployed = false;
            pc.shared_folder_on_local = obj.working_dir;
            assertEqual(pc.working_directory ,'some_irrelevant_folder_never_used_here');
            assertEqual(pc.shared_folder_on_local,obj.working_dir);
            assertEqual(pc.shared_folder_on_remote,obj.working_dir);
            
            
            mpi.send_job_info(data_struct);
            [filename,filepath,is_on_shared] = mpi.par_config_file(pc.shared_folder_on_local);
            info_file = fullfile(filepath,filename);
            rfl = fileparts(filepath);
            clob3 = onCleanup(@()rmdir(rfl,'s'));
            assertEqual(exist(info_file,'file'),2);
            assertFalse(is_on_shared);
            %-------------------------------------------------------------
            % ensure default configuration location will be restored after
            % the test
            clob5 = onCleanup(@()config_store.instance('clear'));
            %
            remote_config_folder = fullfile(pc.shared_folder_on_remote,...
                config_store.config_folder_name);
            % remove all configurations from memory to ensure they would be
            % read from non-default locations.
            config_store.instance('clear');
            
            % these operations would happen on worker
            mis.is_deployed = true;
            config_store.set_config_folder(remote_config_folder)
            
            % on a deployed program woring directory coinsides with shared_folder_on_remote
            pc = parallel_config;
            assertEqual(pc.working_directory ,pc.shared_folder_on_remote);
            
            
            r_config_folder = config_store.instance().config_folder;
            assertEqual(r_config_folder,remote_config_folder);
            [rest_info,exchange_f] = mpi.receive_job_info(r_config_folder);
            assertEqual(data_struct,rest_info);
            assertEqual(exchange_f,fullfile(r_config_folder,mpi.exchange_folder_name))
            
            assertFalse(exist(info_file,'file')==2);
        end
        function test_mpi_worker_single_thread(obj,varargin)
            if nargin>1
                clob1 = onCleanup(@()tearDown(obj));
            end
            
            
            mis = MPI_State.instance();
            mis.is_tested = true;
            clob3 = onCleanup(@()set(mis,'is_deployed',false,'is_tested',false));
            
            pc = parallel_config;
            pc.shared_folder_on_local = obj.working_dir;
            
            mpi_comm = FilebasedMessages();
            mpi_comm = mpi_comm.distribute_worker_init(pc.shared_folder_on_local,...
                'JETester',false);
            
            [~,mess_exchange_folder] = mpi_comm.par_config_file(obj.working_dir);
            assertTrue(exist(mess_exchange_folder,'dir') == 7)
            clob4 = onCleanup(@()rmdir(mess_exchange_folder,'s'));
            
            
            % JETester specific control parameters
            job_param = struct('filepath',obj.working_dir,...
                'filename_template','test_jobDispatcherL%d_nf%d.txt');
            jobControl = InitMessage(job_param,[],3);
            

            
            mpi_comm.send_message(1,jobControl);
            
            
            shared_folder_on_remote = obj.working_dir;
            cs  = mpi_comm.build_framework_init(shared_folder_on_remote,mpi_comm.job_id,1,1);
            
            worker(cs);
        end
        function test_mpi_worker_multi_thread(obj)
            pc = parallel_config;
            cur_config = pc.get_data_to_store;
            clob1 = onCleanup(@()set(pc,cur_config));
            pc.parallel_framework = 'parpool';
            if ~strcmpi(pc.parallel_framework,'parpool') % no access to parallel computing toolbox -- no testing
                return;
            end
            
            
        end
        
    end
end


