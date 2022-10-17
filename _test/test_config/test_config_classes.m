classdef test_config_classes< TestCase
    % Test basic functionality of configuration classes
    %
    %   > >test_config_classes
    %
    % Author: T.G.Perring
    properties
        s0_def;
        s1_def;
        s2_def;
    end

    methods
        function obj = test_config_classes(name)

            obj = obj@TestCase(name);

            %banner_to_screen(mfilename)

            % Set test config classes
            set(tgp_test_class,'default');
            set(tgp_test_class1,'default');
            set(tgp_test_class2,'default');

            ws = warning('off','HERBERT:config_store:runtime_error');
            clob = onCleanup(@()warning(ws));

            obj.s0_def = get(tgp_test_class);
            obj.s1_def = get(tgp_test_class1);
            obj.s2_def = get(tgp_test_class2);

        end

        function obj = test_getstruct(obj)
            config_store.instance().clear_config(tgp_test_class2,'-files');
            ws = warning('off','HERBERT:config_store:runtime_error');
            clob = onCleanup(@()warning(ws));

            % ----------------------------------------------------------------------------
            % Test getting values from a configuration
            % ----------------------------------------------------------------------------
            s2_def_pub = get(tgp_test_class2);
            assertTrue(isequal(fieldnames(s2_def_pub),{'v1';'v2';'v3';'v4'}))
            assertTrue(isequal(obj.s2_def.v1,s2_def_pub.v1))
            assertTrue(isequal(obj.s2_def.v2,s2_def_pub.v2))

            [v1,v3] = get(tgp_test_class2,'v1','v3');

            assertTrue(isequal(obj.s2_def.v1,v1),'Problem with: get(test2_config,''v1'',''v3'')')
            assertTrue(isequal(obj.s2_def.v3,v3),'Problem with: get(test2_config,''v1'',''v3'')')

            config_store.instance().clear_config(tgp_test_class2,'-files');
        end

        function obj = test_get_wrongCase(obj)
            % This should fail because V3 is upper case, but the field is v3
            ws = warning('off','HERBERT:config_store:runtime_error');
            clob = onCleanup(@()warning(ws));

            try
                [v1,v3] = get(tgp_test_class2,'v1','V3');
                ok = false;
            catch
                ok = true;
            end
            assertTrue(ok,'Problem with: get(test2_config,''v1'',''V3'')')

        end

        function obj = test_get_and_save(obj)
            % ----------------------------------------------------------------------------
            % Test getting values and saving
            % ----------------------------------------------------------------------------
            % Change the config without saving, change to default without saving - see that this is done properly
            ws = warning('off','HERBERT:config_store:runtime_error');
            clob = onCleanup(@()warning(ws));

            set(tgp_test_class2,'v1',55,'-buffer');
            s2_buf = get(tgp_test_class2);

            set(tgp_test_class2,'def','-buffer');
            s2_tmp = get(tgp_test_class2);

            assertTrue(~isequal(s2_tmp,s2_buf),'Error in config classes code');
            assertTrue(isequal(s2_tmp,obj.s2_def),'Error in config classes code');

            config_store.instance().clear_config(tgp_test_class2,'-files');
        end

        function obj = test_set_withbuffer(obj)
            set(tgp_test_class2,'v1',-30);
            s2_sav = get(tgp_test_class2);

            % Change the config without saving, change to save values, see this done properly
            set(tgp_test_class2,'v1',55,'-buffer');
            s2_buf = get(tgp_test_class2);

            set(tgp_test_class2,'save');
            s2_tmp = get(tgp_test_class2);

            assertTrue(~isequal(s2_tmp,s2_buf),'Error in config classes code')
            assertTrue(isequal(s2_tmp,s2_sav),'Error in config classes code')

            config_store.instance().clear_config(tgp_test_class2,'-files');
        end

        function obj = test_set_herbert_tests(obj)
            % Use presence or otherwise of TestCaseWithSave as a proxy for xunit tests on
            hc = herbert_config;
            old_config = hc.get_data_to_store();
            clob = onCleanup(@()set(hc,old_config));
            % Tests should be found as we are currently in a test suite
            found_on_entry = ~isempty(which('TestCaseWithSave.m'));
            assertTrue(found_on_entry);

            % Turn off tests
            set(herbert_config,'init_tests',0,'-buffer');
            found_when_init_tests_off = ~isempty(which('TestCaseWithSave.m'));

            % Turn tests back on
            set(herbert_config,'init_tests',1,'-buffer');
            found_when_init_tests_on = ~isempty(which('TestCaseWithSave.m'));

            % Can only use assertTrue, assertFalse etc when tests are on
            assertFalse(found_when_init_tests_off,' folder was not removed from search path properly');
            assertTrue(found_when_init_tests_on);
        end

        function obj = test_parallel_config_fake_worker(obj)
            pc = parallel_config_tester;
            old_config = pc.get_data_to_store();
            clob = onCleanup(@()set(pc,old_config));

            pc = pc.set_worker('non_existing_worker');

            pc.worker = 'non_existing_worker';
            assertEqual(pc.worker,'non_existing_worker');
            assertEqual(pc.parallel_cluster,'none');
            assertEqual(pc.cluster_config,'none');
        end

        function obj = test_parallel_config_missing_worker(obj)
            pc = parallel_config;
            old_config = pc.get_data_to_store();
            clob = onCleanup(@()set(pc,old_config));

            f = @()set(pc,'worker','non_existing_worker');
            assertExceptionThrown(f,'HORACE:parallel_config:invalid_argument');
        end

        function obj = test_parallel_config_slurm_commands_parser(obj)
            pc = parallel_config();
            old_config = pc.get_data_to_store();
            clob = onCleanup(@()set(pc,old_config));
            pc.saveable = false;

            % Sets for comparison
            new_commands = containers.Map({'-A' '-p'}, {'account' 'partition'});
            new_commands_app = containers.Map({'-p' '-q'}, {'new_part' 'queue'});
            new_commands_app_check = containers.Map({'-A' '-p' '-q'}, {'account' 'new_part' 'queue'});

            %% Destructive
            % Set as map
            pc.slurm_commands = new_commands;
            assertEqual(pc.slurm_commands.keys(), new_commands.keys());
            assertEqual(pc.slurm_commands.values(), new_commands.values());

            % Set empty (check clearing works)
            pc.slurm_commands = [];
            assertTrue(isempty(pc.slurm_commands))

            % Set as char
            pc.slurm_commands = [];
            pc.slurm_commands = '-A account -p=partition';
            assertEqual(pc.slurm_commands.keys(), new_commands.keys());
            assertEqual(pc.slurm_commands.values(), new_commands.values());


            % Set as cellstr of commands
            pc.slurm_commands = [];
            pc.slurm_commands = {'-A' 'account' '-p' 'partition'};
            assertEqual(pc.slurm_commands.keys(), new_commands.keys());
            assertEqual(pc.slurm_commands.values(), new_commands.values());

            % Set as cell array of pairs of commands
            pc.slurm_commands = [];
            pc.slurm_commands = {{'-A' 'account'} {'-p' 'partition'}};
            assertEqual(pc.slurm_commands.keys(), new_commands.keys());
            assertEqual(pc.slurm_commands.values(), new_commands.values());

            % Using update_slurm_commands
            pc.slurm_commands = [];
            pc.update_slurm_commands('-A account -p=partition', false);
            assertEqual(pc.slurm_commands.keys(), new_commands.keys());
            assertEqual(pc.slurm_commands.values(), new_commands.values());

            %% Non-destructive
            % Using update_slurm_commands omitting append
            pc.slurm_commands = new_commands;
            pc.update_slurm_commands(new_commands_app);
            assertEqual(pc.slurm_commands.keys(), new_commands_app_check.keys());
            assertEqual(pc.slurm_commands.values(), new_commands_app_check.values());

            % Set through Map interface
            pc.slurm_commands = new_commands;
            pc.slurm_commands('-q') = 'queue';
            pc.slurm_commands('-p') = 'new_part';
            assertEqual(pc.slurm_commands.keys(), new_commands_app_check.keys());
            assertEqual(pc.slurm_commands.values(), new_commands_app_check.values());

            % Set through update_slurm_commands
            pc.slurm_commands = new_commands;
            pc.update_slurm_commands('-q queue -p=new_part', true);
            assertEqual(pc.slurm_commands.keys(), new_commands_app_check.keys());
            assertEqual(pc.slurm_commands.values(), new_commands_app_check.values());

        end

    end
end
