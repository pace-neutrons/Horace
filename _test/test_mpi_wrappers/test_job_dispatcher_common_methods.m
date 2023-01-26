classdef test_job_dispatcher_common_methods < TestCase & FakeJenkins4Tests

    properties
        working_dir
        current_config
        fjenkins_herbert_cobnfig = 'defaults';
    end

    properties (Constant)
        sample_data_cell_str = {'aaa','bbbb','s','aaanana'};
        sample_data_cell_num = {10,20,3,14};
        sample_data_struct = cell2struct({{'aaa','bbbb','s','aaanana'}; {10,20,3,14}},...
                                         {'text_param','num_param'});
        sample_data_cell_mix = {'aaa',[1,2,3,4],'s',10};
        sample_data_nsteps = 4
        sample_data_arr = [1:4]
    end

    methods

        function obj=test_job_dispatcher_common_methods(name)
            if ~exist('name', 'var')
                name = 'test_job_dispatcher_common_methods';
            end
            obj = obj@TestCase(name);
            obj.working_dir = tmp_dir;
            pc = parallel_config;

            obj.current_config = pc.get_data_to_store;

        end

        function clear_jenkins_var(obj)
            % clear fake Jenkins configuration, for is_jenkins routine
            % returning false
            clear_jenkins_var@FakeJenkins4Tests(obj);

            config_store.instance().clear_all();
            hc= hor_config;
            set(hc,obj.fjenkins_herbert_cobnfig);
            hc.init_tests = true;

            obj.working_dir = tmp_dir();
        end

        function set_up_fake_jenkins(obj)
            % set up fake Jenkins configuration, for is_jenkins routine
            % returning true
            set_up_fake_jenkins@FakeJenkins4Tests(obj,'test_jenkins_dispatcher_common');

            hrc = hor_config;
            obj.fjenkins_herbert_cobnfig = hrc.get_data_to_store();
            obj.working_dir = tmp_dir();
        end

        function tearDown(obj)
            % Here we restore the initial configuration as the previous
            % configuration may be restored on remote machine
            pc = parallel_config;
            set(pc,obj.current_config);
        end

        function test_split_job_struct_1_worker(obj)
            jd = JDTester('test_split_job_struct');
            clo = onCleanup(@()(jd.mess_framework.finalize_all()));

            [task_ids,init_mess]= jd.split_tasks([],obj.sample_data_struct,true,1);

            n_workers = numel(task_ids);

            assertEqual(n_workers,1);
            assertEqual(numel(init_mess{1}.loop_data),1)
            assertEqual(numel(init_mess{1}.loop_data.text_param),numel(obj.sample_data_cell_str));
            assertEqual(init_mess{1}.loop_data,obj.sample_data_struct);

        end

        function test_split_job_struct_3_workers(obj)
            jd = JDTester('test_split_job_struct');
            clo = onCleanup(@()(jd.mess_framework.finalize_all()));

            [task_ids,init_mess]= jd.split_tasks([],obj.sample_data_struct,false,3);
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

        function test_split_job_struct_4_workers(obj)
            jd = JDTester('test_split_job_struct');
            clo = onCleanup(@()(jd.mess_framework.finalize_all()));

            [task_ids,init_mess]= jd.split_tasks([],obj.sample_data_struct,false,4);
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
        end

        function test_split_job_cell_1_worker(obj)
            jd = JDTester('test_split_job_cell');
            clo = onCleanup(@()(jd.mess_framework.finalize_all()));

            [task_ids,init_mess]= jd.split_tasks([],obj.sample_data_cell_mix,true,1);
            n_workers = numel(task_ids);

            assertEqual(n_workers,1);
            assertEqual(numel(init_mess{1}.loop_data),numel(obj.sample_data_cell_mix));
            assertEqual(init_mess{1}.loop_data,obj.sample_data_cell_mix);

        end

        function test_split_job_cell_2_workers(obj)
            jd = JDTester('test_split_job_cell');
            clo = onCleanup(@()(jd.mess_framework.finalize_all()));

            [task_ids,init_mess] = jd.split_tasks([],obj.sample_data_cell_mix,true,2);
            n_workers = numel(task_ids);

            assertEqual(n_workers,2);
            assertEqual(numel(init_mess{1}),1)
            assertEqual(numel(init_mess{2}),1)
            assertEqual(init_mess{1}.loop_data,obj.sample_data_cell_mix(1:2))
            assertEqual(init_mess{2}.loop_data,obj.sample_data_cell_mix(3:4))

        end

        function test_split_job_cell_3_workers(obj)
            jd = JDTester('test_split_job_cell');
            clo = onCleanup(@()(jd.mess_framework.finalize_all()));

            [task_ids,init_mess] = jd.split_tasks([],obj.sample_data_cell_mix,true,3);
            n_workers = numel(task_ids);

            assertEqual(n_workers,3);
            assertEqual(init_mess{1}.loop_data,obj.sample_data_cell_mix(1))
            assertEqual(init_mess{2}.loop_data,obj.sample_data_cell_mix(2))
            assertEqual(init_mess{3}.loop_data,obj.sample_data_cell_mix(3:4))
            assertEqual(init_mess{3}.n_first_step,1)
            assertEqual(init_mess{3}.n_steps,2)


        end

        function test_split_job_cell_4_workers(obj)
            jd = JDTester('test_split_job_cell');
            clo = onCleanup(@()(jd.mess_framework.finalize_all()));

            [task_ids,init_mess] = jd.split_tasks([],obj.sample_data_cell_mix,true,4);
            n_workers = numel(task_ids);

            assertEqual(n_workers,4);
            assertEqual(init_mess{1}.loop_data,obj.sample_data_cell_mix(1))
            assertEqual(init_mess{2}.loop_data,obj.sample_data_cell_mix(2))
            assertEqual(init_mess{3}.loop_data,obj.sample_data_cell_mix(3))
            assertEqual(init_mess{4}.loop_data,obj.sample_data_cell_mix(4))

        end

        function test_split_job_cell_5_workers(obj)
            jd = JDTester('test_split_job_cell');
            clo = onCleanup(@()(jd.mess_framework.finalize_all()));

            [task_ids,init_mess] = jd.split_tasks([],obj.sample_data_cell_mix,true,5);
            n_workers = numel(task_ids);
            assertEqual(n_workers,4);
            assertEqual(init_mess{1}.loop_data,obj.sample_data_cell_mix(1))
            assertEqual(init_mess{2}.loop_data,obj.sample_data_cell_mix(2))
            assertEqual(init_mess{3}.loop_data,obj.sample_data_cell_mix(3))
            assertEqual(init_mess{4}.loop_data,obj.sample_data_cell_mix(4))
            assertEqual(init_mess{4}.n_first_step,1)
            assertEqual(init_mess{4}.n_steps,1)
        end

        function test_split_job_arr_1_worker(obj)
            jd = JDTester('test_split_job_arr');
            clo = onCleanup(@()(jd.mess_framework.finalize_all()));

            [task_ids,init_mess]= jd.split_tasks([],obj.sample_data_arr,true,1);
            n_workers = numel(task_ids);

            assertEqual(n_workers,1);
            assertEqual(numel(init_mess{1}.loop_data),numel(obj.sample_data_arr));
            assertEqual(init_mess{1}.loop_data,obj.sample_data_arr);

        end

        function test_split_job_arr_2_workers(obj)
            jd = JDTester('test_split_job_arr');
            clo = onCleanup(@()(jd.mess_framework.finalize_all()));

            [task_ids,init_mess] = jd.split_tasks([],obj.sample_data_arr,true,2);
            n_workers = numel(task_ids);

            assertEqual(n_workers,2);
            assertEqual(numel(init_mess{1}),1)
            assertEqual(numel(init_mess{2}),1)
            assertEqual(init_mess{1}.loop_data,obj.sample_data_arr(1:2))
            assertEqual(init_mess{2}.loop_data,obj.sample_data_arr(3:4))

        end

        function test_split_job_arr_3_workers(obj)
            jd = JDTester('test_split_job_arr');
            clo = onCleanup(@()(jd.mess_framework.finalize_all()));

            [task_ids,init_mess] = jd.split_tasks([],obj.sample_data_arr,true,3);
            n_workers = numel(task_ids);

            assertEqual(n_workers,3);
            assertEqual(init_mess{1}.loop_data,obj.sample_data_arr(1))
            assertEqual(init_mess{2}.loop_data,obj.sample_data_arr(2))
            assertEqual(init_mess{3}.loop_data,obj.sample_data_arr(3:4))
            assertEqual(init_mess{3}.n_first_step,1)
            assertEqual(init_mess{3}.n_steps,2)


        end

        function test_split_job_arr_4_workers(obj)
            jd = JDTester('test_split_job_arr');
            clo = onCleanup(@()(jd.mess_framework.finalize_all()));

            [task_ids,init_mess] = jd.split_tasks([],obj.sample_data_arr,true,4);
            n_workers = numel(task_ids);

            assertEqual(n_workers,4);
            assertEqual(init_mess{1}.loop_data,obj.sample_data_arr(1))
            assertEqual(init_mess{2}.loop_data,obj.sample_data_arr(2))
            assertEqual(init_mess{3}.loop_data,obj.sample_data_arr(3))
            assertEqual(init_mess{4}.loop_data,obj.sample_data_arr(4))

        end

        function test_split_job_arr_5_workers(obj)
            jd = JDTester('test_split_job_arr');
            clo = onCleanup(@()(jd.mess_framework.finalize_all()));

            [task_ids,init_mess] = jd.split_tasks([],obj.sample_data_arr,true,5);
            n_workers = numel(task_ids);
            assertEqual(n_workers,4);
            assertEqual(init_mess{1}.loop_data,obj.sample_data_arr(1))
            assertEqual(init_mess{2}.loop_data,obj.sample_data_arr(2))
            assertEqual(init_mess{3}.loop_data,obj.sample_data_arr(3))
            assertEqual(init_mess{4}.loop_data,obj.sample_data_arr(4))
            assertEqual(init_mess{4}.n_first_step,1)
            assertEqual(init_mess{4}.n_steps,1)
        end

        function test_split_job_nsteps_1_worker(obj)
            jd = JDTester('test_split_job_nsteps');
            clo = onCleanup(@()(jd.mess_framework.finalize_all()));
            [task_ids,init_mess]= jd.split_tasks([],obj.sample_data_nsteps,false,1);
            n_workers = numel(task_ids);

            assertEqual(n_workers,1);
            assertEqual(numel(init_mess),1);
            assertEqual(init_mess{1}.n_first_step,1);
            assertEqual(init_mess{1}.n_steps,4);

        end

        function test_split_job_nsteps_2_workers(obj)
            jd = JDTester('test_split_job_nsteps');
            clo = onCleanup(@()(jd.mess_framework.finalize_all()));
            [task_ids,init_mess] = jd.split_tasks([],obj.sample_data_nsteps,true,2);
            n_workers = numel(task_ids);

            assertEqual(n_workers,2);
            assertEqual(init_mess{1}.n_first_step,1)
            assertEqual(init_mess{1}.n_steps,2)

            assertEqual(init_mess{2}.n_first_step,3)
            assertEqual(init_mess{2}.n_steps,2)

        end

        function test_split_job_nsteps_3_workers(obj)
            jd = JDTester('test_split_job_nsteps');
            clo = onCleanup(@()(jd.mess_framework.finalize_all()));
            [task_ids,init_mess] = jd.split_tasks([],obj.sample_data_nsteps,false,3);
            n_workers = numel(task_ids);

            assertEqual(n_workers,3);
            assertEqual(init_mess{1}.n_first_step,1)
            assertEqual(init_mess{1}.n_steps,1)

            assertEqual(init_mess{2}.n_first_step,2)
            assertEqual(init_mess{2}.n_steps,1)

            assertEqual(init_mess{3}.n_first_step,3)
            assertEqual(init_mess{3}.n_steps,2)

        end

        function test_split_job_nsteps_4_workers(obj)
            jd = JDTester('test_split_job_nsteps');
            clo = onCleanup(@()(jd.mess_framework.finalize_all()));
            [task_ids,init_mess] = jd.split_tasks([],obj.sample_data_nsteps,true,4);
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
        end

        function test_transfer_init_and_config_on_fake_jenkins(obj)
            if is_jenkins() % do not run it on real Jenkins, it may mess
                % the whole Jenkins enviroment
                return;
            end
            obj.set_up_fake_jenkins();
            clearJenkinsSignature = onCleanup(@()clear_jenkins_var(obj));

            assertTrue(is_jenkins);
            % clear configuration from memory to ensure the configuration
            % will be rebuild as Jenkins configuration
            config_store.instance().clear_all();


            obj.test_transfer_init_and_config()

            clear clearJenkinsSignature;
            assertFalse(is_jenkins);

        end

        function test_transfer_init_and_config(obj, varargin)
            % testing the transfer of the initial information for a Herbert
            % job through a data exchange folder


            % ensure tests are enabled
            hc = hor_config;
            hc.init_tests= true;

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
            assertTrue(is_file(fullfile(config_exchange, 'hor_config.mat')));

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
