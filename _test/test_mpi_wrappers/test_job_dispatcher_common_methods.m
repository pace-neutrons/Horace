classdef test_job_dispatcher_common_methods < TestCase
   
    properties
        working_dir
        current_config
    end
    methods
        %
        function obj=test_job_dispatcher_common_methods(name)
            if ~exist('name', 'var')
                name = 'test_job_dispatcher_common_methods';
            end
            obj = obj@TestCase(name);
            obj.working_dir = tmp_dir;
            pc = parallel_config;
            
            obj.current_config = pc.get_data_to_store;
            
        end
        function tearDown(obj)
            % Here we restore the initial configuration as the previous
            % configuration may be restored on remote machine
            pc = parallel_config;
            set(pc,obj.current_config);
        end
        
        function test_split_job_struct(~)        
            common_par = [];
            l1= {'aaa','bbbb','s','aaanana'};
            l2 = {10,20,3,14};
            
            loop_par = cell2struct({l1;l2},{'text_param','num_param'});
            
            jd = JDTester('test_split_job_struct');
            clo = onCleanup(@()(jd.mess_framework.finalize_all()));

            [task_ids,init_mess]= jd.split_tasks(common_par,loop_par,true,1);

            n_workers = numel(task_ids);
            
            assertEqual(n_workers,1);
            assertEqual(numel(init_mess{1}.loop_data),1)
            assertEqual(numel(init_mess{1}.loop_data.text_param),numel(l1));
            assertEqual(init_mess{1}.loop_data,loop_par);
           
            [task_ids,init_mess]= jd.split_tasks(common_par,loop_par,false,4);
            n_workers = numel(task_ids);
            
            assertEqual(n_workers,4);
            assertEqual(numel(init_mess),4);
            assertEqual(init_mess{1}.n_first_step,1);
            assertEqual(init_mess{1}.n_steps,1);            
            assertEqual(init_mess{4}.n_first_step,1);
            assertEqual(init_mess{4}.n_steps,1);
            
            s2 = init_mess{2}.loop_data;
            assertEqual(s2.text_param,{'bbbb'});
            assertEqual(s2.num_param,{20});            

            
            [task_ids,init_mess]= jd.split_tasks(common_par,loop_par,false,3);
            n_workers = numel(task_ids);
            
            assertEqual(n_workers,3);
            assertEqual(numel(init_mess),3);
            assertEqual(init_mess{1}.n_first_step,1);
            assertEqual(init_mess{1}.n_steps,1);
            assertEqual(init_mess{3}.n_first_step,1);
            assertEqual(init_mess{3}.n_steps,2);
            s3 = init_mess{3}.loop_data;
            assertEqual(s3.text_param,{'s','aaanana'});
            assertEqual(s3.num_param,{3,14});            

            
        end
        %
        function test_split_job_list(~)
            % split job list into batches and prepare init messages
            %
            common_par = [];
            loop_par = {'aaa','bbbb','s','aaanana'};
            
            jd = JDTester('test_split_job_list');
            clo = onCleanup(@()(jd.mess_framework.finalize_all()));
            
            [task_ids,init_mess]= jd.split_tasks(common_par,loop_par,true,1);
            n_workers = numel(task_ids);
            
            assertEqual(n_workers,1);
            assertEqual(numel(init_mess{1}.loop_data),numel(loop_par));
            assertEqual(init_mess{1}.loop_data,loop_par);
            
            [task_ids,init_mess]= jd.split_tasks(common_par,4,false,1);
            n_workers = numel(task_ids);
            
            assertEqual(n_workers,1);
            assertEqual(numel(init_mess),1);
            assertEqual(init_mess{1}.n_first_step,1);
            assertEqual(init_mess{1}.n_steps,4);
            
            %-------------------------------------------------------------
            
            loop_par = {'aaa',[1,2,3,4],'s',10};
            [task_ids,init_mess] = jd.split_tasks(common_par,loop_par,true,2);
            n_workers = numel(task_ids);
            
            assertEqual(n_workers,2);
            assertEqual(numel(init_mess{1}),1)
            assertEqual(numel(init_mess{2}),1)
            assertEqual(init_mess{1}.loop_data,loop_par(1:2))
            assertEqual(init_mess{2}.loop_data,loop_par(3:4))
            
            
            [task_ids,init_mess] = jd.split_tasks(common_par,4,true,2);
            n_workers = numel(task_ids);
            
            assertEqual(n_workers,2);
            assertEqual(init_mess{1}.n_first_step,1)
            assertEqual(init_mess{1}.n_steps,2)
            
            assertEqual(init_mess{2}.n_first_step,3)
            assertEqual(init_mess{2}.n_steps,2)
            %-------------------------------------------------------------
            
            [task_ids,init_mess] = jd.split_tasks(common_par,loop_par,true,3);
            n_workers = numel(task_ids);
            
            assertEqual(n_workers,3);
            assertEqual(init_mess{1}.loop_data,loop_par(1))
            assertEqual(init_mess{2}.loop_data,loop_par(2))
            assertEqual(init_mess{3}.loop_data,loop_par(3:4))
            assertEqual(init_mess{3}.n_first_step,1)
            assertEqual(init_mess{3}.n_steps,2)
            
            
            [task_ids,init_mess] = jd.split_tasks(common_par,4,false,3);
            n_workers = numel(task_ids);
            
            assertEqual(n_workers,3);
            assertEqual(init_mess{1}.n_first_step,1)
            assertEqual(init_mess{1}.n_steps,1)
            
            assertEqual(init_mess{2}.n_first_step,2)
            assertEqual(init_mess{2}.n_steps,1)
            
            assertEqual(init_mess{3}.n_first_step,3)
            assertEqual(init_mess{3}.n_steps,2)
            
            %-------------------------------------------------------------
            
            [task_ids,init_mess] = jd.split_tasks(common_par,loop_par,true,4);
            n_workers = numel(task_ids);
            
            assertEqual(n_workers,4);
            assertEqual(init_mess{1}.loop_data,loop_par(1))
            assertEqual(init_mess{2}.loop_data,loop_par(2))
            assertEqual(init_mess{3}.loop_data,loop_par(3))
            assertEqual(init_mess{4}.loop_data,loop_par(4))
            
            [task_ids,init_mess] = jd.split_tasks(common_par,4,true,4);
            n_workers = numel(task_ids);
            
            assertEqual(n_workers,4);
            assertEqual(init_mess{1}.n_first_step,1)
            assertEqual(init_mess{1}.n_steps,1)
            assertEqual(init_mess{2}.n_first_step,2)
            assertEqual(init_mess{2}.n_steps,1)
            assertEqual(init_mess{3}.n_first_step,3)
            assertEqual(init_mess{3}.n_steps,1)
            assertEqual(init_mess{4}.n_first_step,4)
            assertEqual(init_mess{4}.n_steps,1)
            
            
            %-------------------------------------------------------------
            [task_ids,init_mess] = jd.split_tasks(common_par,loop_par,true,5);
            n_workers = numel(task_ids);
            assertEqual(n_workers,4);
            assertEqual(init_mess{1}.loop_data,loop_par(1))
            assertEqual(init_mess{2}.loop_data,loop_par(2))
            assertEqual(init_mess{3}.loop_data,loop_par(3))
            assertEqual(init_mess{4}.loop_data,loop_par(4))
            assertEqual(init_mess{4}.n_first_step,1)
            assertEqual(init_mess{4}.n_steps,1)
            %-------------------------------------------------------------
        end        
        %
        function test_transfer_init_and_config(obj, varargin)
            % testing the transfer of the initial information for a Herbert
            % job through a data exchange folder
            %
            % Prepare current configuration to be able to restore it after
            % the test finishes
            
            % set up basic default configuration
            pc = parallel_config;
            pc.saveable = false;
            % creates working directory
            pc.working_directory = fullfile(obj.working_dir, 'some_irrelevant_folder_never_used_here');
            wkdir0 = pc.working_directory;
            clobW = onCleanup(@()rmdir(wkdir0, 's'));
            
            %--------------------------------------------------------------
            % check the case when local file system and remote file system
            % coincide
            
            pc.shared_folder_on_remote = '';
            pc.shared_folder_on_local = '';
            
            % test structure to send
            % store configuration in a local config folder as local and
            % remote jobs have the same file system
            mpi = MessagesFilebased('testiMPI_transferInit');
            mpi.mess_exchange_folder = obj.working_dir;
            clob0 = onCleanup(@()finalize_all(mpi));
            % the operation above copies config files to the folder
            % calculated by assign operation
            config_exchange = fileparts(fileparts(mpi.mess_exchange_folder));
            assertTrue(is_file(fullfile(config_exchange, 'herbert_config.mat')));
            
            jt = JETester();
            initMess = jt.get_worker_init();
            assertTrue(isa(initMess, 'aMessage'));
            data = initMess.payload;
            assertTrue(data.exit_on_compl);
            assertFalse(data.keep_worker_running);
            
            % simulate the configuration operations happening on a remote machine side
            mis = MPI_State.instance();
            mis.is_deployed = true;
            mis.is_tested = true;
            clob4 = onCleanup(@()set(mis, 'is_deployed', false, 'is_tested', false));
            % the filesystem is shared so working_directory is used as
            % shared folder
            wk_dir = fullfile(obj.working_dir, 'some_irrelevant_folder_never_used_here');
            assertEqual(pc.working_directory, wk_dir);
            assertEqual(pc.shared_folder_on_local, wk_dir);
            assertEqual(pc.shared_folder_on_remote, wk_dir);
            
            
            %--------------------------------------------------------------
            %now test storing/restoring project configuration from a
            %directory different from default.
            mis.is_deployed = false;
            pc.shared_folder_on_local = obj.working_dir;
            assertEqual(pc.working_directory, wk_dir);
            assertEqual(pc.shared_folder_on_local, obj.working_dir);
            assertEqual(pc.shared_folder_on_remote, obj.working_dir);
            
            
            %-------------------------------------------------------------
            % ensure default configuration location will be restored after
            % the test
            clob5 = onCleanup(@()config_store.instance('clear'));
            %
            cfn = config_store.instance().config_folder_name;
            remote_config_folder = fullfile(pc.shared_folder_on_remote, ...
                cfn);
            clob6 = onCleanup(@()rmdir(remote_config_folder, 's'));
            % remove all configurations from memory to ensure they would be
            % read from non-default locations.
            config_store.instance('clear');
            
            % these operations would happen on worker
            mis.is_deployed = true;
            config_store.set_config_folder(remote_config_folder)
            
            % on a deployed program working directory coincides with shared_folder_on_remote
            pc = parallel_config;
            assertEqual(pc.working_directory, pc.shared_folder_on_remote);
            
            
            r_config_folder = config_store.instance().config_folder;
            assertEqual(r_config_folder, remote_config_folder);
        end
        
    end
end
