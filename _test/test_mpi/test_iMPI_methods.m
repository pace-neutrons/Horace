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
        function test_transfer_init(obj)
            % testing the transfer of the initial information for a Herbert
            % job through a data exchange folder
            pc = parallel_config;
            cur_config = pc.get_data_to_store;
            clob1 = onCleanup(@()set(pc,cur_config));
            cs = config_store.instance();
            current_config_folder = cs.config_folder;
            clob2 = onCleanup(@()set_config_path(cs,current_config_folder));
            
            
            data_struct = struct('some_field',1,'other_field','bbbb');
            
            % store configuration in a local config folder as local and
            % remote jobs have the same file system
            mpi = iMPITestHelper();
            mpi.send_job_info(data_struct);
            
            info_file = mpi.get_config_file_name();
            clob3 = onCleanup(@()delete(info_file));
            assertEqual(exist(info_file,'file'),2);
            
            [rest_info,config_f] = mpi.receive_job_info(current_config_folder);
            assertEqual(data_struct,rest_info);
            assertEqual(config_f,current_config_folder)
            
            %now test storing/restoring project configuration from a
            %directory different from default.
            pc.remote_folder = obj.working_dir;
            mpi.send_job_info(data_struct);
            info_file = mpi.config_file_name;
            clob3 = onCleanup(@()delete(info_file));
            assertEqual(exist(info_file,'file'),2);
            
            %remote_config_folder = fullfile(
        end
    end
end


