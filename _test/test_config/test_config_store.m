classdef test_config_store < TestCase
    properties
        config_store_path;
    end
    methods
        %
        function this=test_config_store (name)
            this = this@TestCase(name);
            this.config_store_path = config_store.instance().config_folder();
        end
        function this=test_store_restore_new_class(this)
            config_store.instance().clear_all()
            
            tsc = some_test_class();
            test_class_name = tsc.class_name;
            
            config_file = fullfile(config_store.instance().config_folder(),[test_class_name ,'.mat']);
            % set up
            if exist(config_file,'file')
                delete(config_file);
            end
            
            config_store.instance().store_config(tsc);
            assertTrue(exist(config_file,'file')==2);
            
            tsc1=config_store.instance().restore_config(tsc);
            
            assertTrue(tsc1 == tsc);
            
            config_store.instance().clear_config(tsc1);
            assertFalse(config_store.instance().is_configured(tsc1,'-in_mem'));
            assertTrue(config_store.instance().is_configured(tsc1));
            
            tsc1=config_store.instance().restore_config(tsc);
            assertTrue(tsc1 == tsc);
            
            assertTrue(config_store.instance().is_configured(tsc,'-in_mem'));

            
            % clean up
            config_store.instance().clear_config(tsc,'-file');
            assertFalse(exist(config_file,'file')==2)
        end
        
        function this=test_two_classes(this)
            config_store.instance().clear_all()
            
            tsc1 = some_test_class();
            test_class_name1 = tsc1.class_name;
            
            tsc2 = some_test_class2();
            test_class_name2 = tsc2.class_name;
            
            config_file1 = fullfile(config_store.instance().config_folder(),[test_class_name1 ,'.mat']);
            config_file2 = fullfile(config_store.instance().config_folder(),[test_class_name2 ,'.mat']);
            % set up
            if exist(config_file1,'file')
                delete(config_file1);
            end
            if exist(config_file2,'file')
                delete(config_file2);
            end
            
            
            config_store.instance().store_config(tsc1);
            config_store.instance().store_config(tsc2);
            assertTrue(exist(config_file1,'file')==2);
            assertTrue(exist(config_file2,'file')==2);
            
            tsc2a=config_store.instance().restore_config(tsc2);
            assertTrue(tsc2a == tsc2);
            
            tsc1a=config_store.instance().restore_config(tsc1);
            assertTrue(tsc1a == tsc1);
            
            
            config_store.instance().clear_config(tsc1,'-file');
            assertFalse(exist(config_file1,'file')==2)
            
            config_store.instance().clear_config(tsc2,'-file');
            assertFalse(exist(config_file2,'file')==2)
            
            assertFalse(config_store.instance().is_configured(tsc1),'-in_mem');
            assertFalse(config_store.instance().is_configured(tsc2),'-in_mem');
            
            assertFalse(config_store.instance().is_configured(tsc1));
            assertFalse(config_store.instance().is_configured(tsc2));
            
        end
        function test_force_save(this)
            config_store.instance().clear_all()
            
            tsc = some_test_class();
            test_class_name = tsc.class_name;
            
            config_file = fullfile(config_store.instance().config_folder(),[test_class_name ,'.mat']);
            % set up
            if exist(config_file,'file')
                delete(config_file);
            end
            
            config_store.instance().store_config(tsc);
            assertTrue(exist(config_file,'file')==2);
            
            if exist(config_file,'file')
                delete(config_file);
            end
            config_store.instance().store_config(tsc);
            assertFalse(exist(config_file,'file')==2);
            
            config_store.instance().store_config(tsc,'-force');
            assertTrue(exist(config_file,'file')==2);
            
            config_store.instance().clear_all('-file')
            assertFalse(exist(config_file,'file')==2);
        end
        
        function test_changed_config(this)
            config_store.instance().clear_all()
            
            tsc = some_test_class();
            test_class_name = tsc.class_name;
            
            config_file = fullfile(config_store.instance().config_folder(),[test_class_name ,'.mat']);
            % set up
            if exist(config_file,'file')
                delete(config_file);
            end
            
            config_store.instance().store_config(tsc);
            assertTrue(exist(config_file,'file')==2);
            if exist(config_file,'file')
                delete(config_file);
            end
            
            tsc1=tsc;
            tsc1.a = 20;
            config_store.instance().store_config(tsc1);
            assertTrue(exist(config_file,'file')==2);
            tsc1a=config_store.instance().restore_config(tsc );
            
            assertTrue(tsc1==tsc1a);
            
            config_store.instance().clear_all('-file')
            assertFalse(exist(config_file,'file')==2);
        end
        
        function test_changed_class(this)
            config_store.instance().clear_all()
            
            tsc = some_test_class();
            test_class_name = tsc.class_name;
            
            config_file = fullfile(config_store.instance().config_folder(),[test_class_name ,'.mat']);
            % set up
            if exist(config_file,'file')
                delete(config_file);
            end
            
            config_store.instance().store_config(tsc);
            assertTrue(exist(config_file,'file')==2);
            tsc1 = some_test_class2();
            % full the loader forcing it to think that the class have
            % changed
            tsc1=tsc1.set_class_name(test_class_name);
            tsc1.a = 100;
            
            config_store.instance().clear_config(tsc1)
            assertFalse(config_store.instance().is_configured(tsc1,'-in_mem'));
            
            wc=warning('off','CONFIG_STORE:restore_config');
            tsc1a=config_store.instance().restore_config(tsc1);
            warning(wc);
            
            assertFalse(exist(config_file,'file')==2);
            assertTrue(tsc1==tsc1a);
            
            tsc1b=config_store.instance().restore_config(tsc1);
            assertTrue(tsc1==tsc1b);             
            
            config_store.instance().clear_all('-file')
            assertFalse(exist(config_file,'file')==2);
            
        end

        
    end
    
end

