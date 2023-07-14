classdef test_config_base < TestCase
    properties
        stored_config;
    end
    methods
        %
        function this=test_config_base (name)
            this = this@TestCase(name);
        end
        function setUp(obj)
            obj.stored_config = config_store.instance().get_all_configs();
        end
        function tearDown(obj)
            config_store.instance().set_all_configs(obj.stored_config);
        end

        function test_store_restore_in_memory(~)
            config = config_base_tester();
            clob = set_temporary_warning('off','HERBERT:config_store:runtime_error');


            config_store.instance().clear_config(config)
            config_file = fullfile(config_store.instance().config_folder(),'config_base_tester.mat');
            % set up
            if is_file(config_file)
                delete(config_file);
            end


            assertEqual('beee',config.my_prop);

            config.my_prop = 'meee';
            assertEqual('meee',config.my_prop);

            config1 = config_base_tester();
            assertEqual('meee',config1.my_prop);
            % clear configuration from memory
            config_store.instance().clear_config(config);

            config2 = config_base_tester();
            assertEqual('meee',config2.my_prop);

            config2.returns_defaults = true;
            assertEqual('beee',config2.my_prop);

            config_store.instance().clear_config(config,'-file')
        end
        %
        function test_set_extern_config_folder_with_config_name(~)
            wkf = fullfile(tmp_dir(),'mprogs_config_blabla');
            config_store.set_config_folder(wkf);
            cfn = config_store.instance().config_folder_name;
            assertEqual(cfn,'mprogs_config_blabla');

            assertEqual(config_store.instance().config_folder,wkf);
        end

        function test_set_extern_folder_with_config_name(~)
            function restore_cfn(cfn,tmp_cfn)
                config_store.instance().set_config_path(cfn);
                rmdir(tmp_cfn);
            end
            wkf = fullfile(tmp_dir(),'mprogs_config_blabla');
            cfn = config_store.instance().config_folder;
            clOb = onCleanup(@()restore_cfn(cfn,wkf));
            config_store.instance().set_config_path(wkf);
            cfn = config_store.instance().config_folder_name;
            assertEqual(cfn,'mprogs_config_blabla');

            assertEqual(config_store.instance().config_folder,wkf);
            clear clOb;
        end
        %
        function test_set_extern_folder_no_config_name(~)
            function restore_cfn(cfn,tmp_cfn)
                config_store.instance().set_config_path(cfn);
                if is_folder(tmp_cfn)
                    rmdir(tmp_cfn);
                end
            end
            cfn = config_store.instance().config_folder;
            wkf = tmp_dir();
            config_store.instance().set_config_path(wkf);
            clOb = onCleanup(@()restore_cfn(cfn,fullfile(wkf,'mprogs_config')));
            cfn = config_store.instance().config_folder_name;

            assertEqual(config_store.instance().config_folder,...
                fullfile(wkf,cfn));
            clear clOb;
        end

        function test_store_restore_in_file(~)
            clob = set_temporary_warning('off','HERBERT:config_store:runtime_error');

            config = config_base_tester();

            config_store.instance().clear_config(config)
            config_file = fullfile(config_store.instance().config_folder(),'config_base_tester.mat');
            % set up
            if is_file(config_file)
                delete(config_file);
            end

            assertEqual('beee',config.my_prop);

            config.my_prop = 'meee';
            assertEqual('meee',config.my_prop);

            config1 = config_base_tester();
            assertEqual('meee',config1.my_prop);

            assertTrue(is_file(config_file));

            set(config_base_tester,'my_prop','veee','-buffer');
            config1 = config_base_tester();
            assertEqual('veee',config1.my_prop);

            % clear configuration from memory
            config_store.instance().clear_config(config);

            config2 = config_base_tester();
            assertEqual('meee',config2.my_prop);

            config2.returns_defaults = true;
            assertEqual('beee',config2.my_prop);

            config_store.instance().clear_config(config,'-file')

            assertFalse(is_file(config_file));
        end

    end

end
