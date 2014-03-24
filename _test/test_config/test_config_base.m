classdef test_config_base < TestCase
    properties
    end
    methods
        %
        function this=test_config_base (name)
            this = this@TestCase(name);
        end
        
        function test_store_restore_in_memory(this)
            config = config_base_tester();
            
            config_store.instance().clear_config(config)
            config_file = fullfile(config_store.instance().config_folder(),'config_base_tester.mat');
            % set up
            if exist(config_file,'file')
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
            
            config2.return_defaults = true;
            assertEqual('beee',config2.my_prop);            
            
            config_store.instance().clear_config(config,'-file')
        end
        
    end
    
end

