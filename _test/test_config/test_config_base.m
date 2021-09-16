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
            ws=warning('off','CONFIG_STORE:restore_config');
            clob = onCleanup(@()warning(ws));
            
            
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
        function test_set_extern_folder_with_config_name(~)
            wkf = fullile(tmp_dir(),'mprogs_config_blabla');
            config_store.instance().set_config_path(wkf);
            cfn = config_store.instance().config_folder_name;
            assertEqual(cfn,'mprogs_config_blabla');
            
            assertEqual(config_store_instance().config_folder_name,...
                fullfile(wkf,'mprogs_config_blabla'));
        end        
        %
        function test_set_extern_folder_no_config_name(~)
            wkf = tmp_dir();
            config_store.instance().set_config_path(wkf);
            cfn = config_store.instance().config_folder_name;
            
            assertEqual(config_store_instance().config_folder_name,...
                fullfile(wkf,cfn));
        end
   
        function test_store_restore_in_file(~)
            ws=warning('off','CONFIG_STORE:restore_config');
            clob = onCleanup(@()warning(ws));
            
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
        end
           
    end
    
end

