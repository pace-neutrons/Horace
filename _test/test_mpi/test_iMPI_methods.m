classdef test_iMPI_methods< TestCase
    %
    % $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)
    %
    
    properties
        working_dir
    end
    methods
        %
        function this=test_iMPI_methods(name)
            if ~exist('name','var')
                name = 'test_iMPI_methods';
            end
            this = this@TestCase(name);
            this.working_dir = tempdir;
        end
        function test_serialize_deserialize(this)
            mf = MFTester('test_ser_deser');
            css = mf.worker_job_info('SomeWorker',3);
            dat = mf.serialize_par(css);
            
            csr = mf.deserialize_par(dat);
            assertEqual(css,csr);
        end
        function test_transfer_init_and_config(obj)
            % testing the transfer of the initial information for a Herbert
            % job through a data exchange folder
            %
            % Prepare current configuration to be able to restore it after
            % the test finishes
            pc = parallel_config;
            cur_config = pc.get_data_to_store;
            clob1 = onCleanup(@()set(pc,cur_config));
            cs = config_store.instance();
            current_config_folder = cs.config_folder;
            clob2 = onCleanup(@()set_config_path(cs,current_config_folder));
            pc.working_directory = 'some_irrelevant_folder_never_used_here';
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
            info_file = mpi.get_par_config_file_name();
            clob3 = onCleanup(@()delete(info_file));
            assertEqual(exist(info_file,'file'),2);
            
            [rest_info,config_f] = mpi.receive_job_info(current_config_folder);
            assertEqual(data_struct,rest_info);
            assertEqual(config_f,fullfile(current_config_folder,mpi.exchange_folder_name))
            %--------------------------------------------------------------
            %now test storing/restoring project configuration from a
            %directory different from default.
            mis.is_deployed = false;
            pc.shared_folder_on_local = obj.working_dir;
            assertEqual(pc.working_directory ,'some_irrelevant_folder_never_used_here');
            assertEqual(pc.shared_folder_on_local,obj.working_dir);
            assertEqual(pc.shared_folder_on_remote,obj.working_dir);
            
            
            mpi.send_job_info(data_struct);
            info_file = mpi.get_par_config_file_name(pc.shared_folder_on_local);
            rfl = fileparts(fileparts(info_file ));
            clob3 = onCleanup(@()rmdir(rfl,'s'));
            assertEqual(exist(info_file,'file'),2);
            %-------------------------------------------------------------
            % ensure default configuration location will be restored
            clob5 = onCleanup(@()config_store.instance('clear'));
            %
            remote_config_folder = fullfile(pc.shared_folder_on_remote,mpi.exchange_folder_name);
            % remove all configurations from memory to ensure they would be
            % read from non-default locations.
            config_store.instance('clear')
            
            % these operations would happen on worker
            config_store.set_config_folder(remote_config_folder)
            
            pc = prallel_config;
            assertEqual(pc.working_directory ,pc.shared_folder_on_remote);
            
            r_config_folder = config_store.instance().config_folder;
            assertEqual(r_config_folder,remote_config_folder);
            [rest_info,config_f] = mpi.receive_job_info(r_config_folder);
            assertEqual(data_struct,rest_info);
            assertEqual(config_f,fullfile(current_config_folder,mpi.exchange_folder_name))
            
        end
    end
end


