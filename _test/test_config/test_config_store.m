classdef test_config_store < TestCase
    properties
        config_store_path;
        cfg;
    end
    methods
        %
        function this=test_config_store (name)
            this = this@TestCase(name);
            this.config_store_path = config_store.instance().config_folder();
        end
        %         function this=setUP(this)
        %             this.cfg = get(conf
        %         end
        function this=tearDown(this)
        end
        function this=test_store_restore_new_class(this)
            % set up
            tsc = some_test_class();
            
            config_store.instance().clear_config(tsc)
            test_class_name = tsc.class_name;
            
            config_file = fullfile(config_store.instance().config_folder(),[test_class_name ,'.mat']);
            if exist(config_file,'file')
                delete(config_file);
            end
            %testing
            
            config_store.instance().store_config(tsc);
            assertTrue(exist(config_file,'file')==2);
            
            tsc1=config_store.instance().get_config(tsc);
            tsc1 = tsc.set_stored_data(tsc1);
            assertTrue(tsc1 == tsc);
            
            config_store.instance().clear_config(tsc1);
            assertFalse(config_store.instance().is_configured(tsc1,'-in_mem'));
            assertTrue(config_store.instance().is_configured(tsc1));
            
            tsc1=config_store.instance().get_config(tsc);
            tsc1 = tsc.set_stored_data(tsc1);
            assertTrue(tsc1 == tsc);
            
            assertTrue(config_store.instance().is_configured(tsc,'-in_mem'));
            
            
            % clean up
            config_store.instance().clear_config(tsc,'-file');
            assertFalse(exist(config_file,'file')==2)
        end
        
        function this=test_two_classes(this)
            % set up
            tsc1 = some_test_class();
            tsc2 = some_test_class2();
            
            config_store.instance().clear_config(tsc1);
            config_store.instance().clear_config(tsc2);
            
            
            test_class_name1 = tsc1.class_name;
            test_class_name2 = tsc2.class_name;
            
            config_file1 = fullfile(config_store.instance().config_folder(),[test_class_name1 ,'.mat']);
            config_file2 = fullfile(config_store.instance().config_folder(),[test_class_name2 ,'.mat']);
            if exist(config_file1,'file')
                delete(config_file1);
            end
            if exist(config_file2,'file')
                delete(config_file2);
            end
            
            %testing
            config_store.instance().store_config(tsc1);
            config_store.instance().store_config(tsc2);
            assertTrue(exist(config_file1,'file')==2);
            assertTrue(exist(config_file2,'file')==2);
            
            tsc2a=config_store.instance().get_config(tsc2);
            tsc2a = tsc2.set_stored_data(tsc2a);
            assertTrue(tsc2a == tsc2);
            
            tsc1a=config_store.instance().get_config(tsc1);
            tsc1a = tsc1.set_stored_data(tsc1a);
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
            % set up
            tsc = some_test_class();            
            config_store.instance().clear_config(tsc)
            
            test_class_name = tsc.class_name;
            
            config_file = fullfile(config_store.instance().config_folder(),[test_class_name ,'.mat']);
            if exist(config_file,'file')
                delete(config_file);
            end
            %testing
            
            config_store.instance().store_config(tsc);
            assertTrue(exist(config_file,'file')==2);
            
            if exist(config_file,'file')
                delete(config_file);
            end
            config_store.instance().store_config(tsc);
            assertFalse(exist(config_file,'file')==2);
            
            config_store.instance().store_config(tsc,'-force');
            assertTrue(exist(config_file,'file')==2);
            
            config_store.instance().clear_config(tsc,'-file')
            assertFalse(exist(config_file,'file')==2);
        end
        
        function test_changed_config(this)
            % set up
            tsc = some_test_class();            
            config_store.instance().clear_config(tsc)           

            test_class_name = tsc.class_name;
            
            config_file = fullfile(config_store.instance().config_folder(),[test_class_name ,'.mat']);
            if exist(config_file,'file')
                delete(config_file);
            end
            %testing
            
            config_store.instance().store_config(tsc);
            assertTrue(exist(config_file,'file')==2);
            if exist(config_file,'file')
                delete(config_file);
            end
            
            tsc1=tsc;
            tsc1.a = 20;
            config_store.instance().store_config(tsc1);
            assertTrue(exist(config_file,'file')==2);
            tsc1a=config_store.instance().get_config(tsc );
            tsc1a = tsc.set_stored_data(tsc1a);
            assertTrue(tsc1==tsc1a);
            
            config_store.instance().clear_config(tsc,'-file')
            assertFalse(exist(config_file,'file')==2);
        end
        
        function test_changed_class(this)
            % set up
            tsc = some_test_class();            
            config_store.instance().clear_config(tsc)            
            test_class_name = tsc.class_name;
            
            config_file = fullfile(config_store.instance().config_folder(),[test_class_name ,'.mat']);
            if exist(config_file,'file')
                delete(config_file);
            end
            % testing
            
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
            tsc1a=config_store.instance().get_config(tsc1);
            warning(wc);
            
            assertFalse(exist(config_file,'file')==2);
            tsc1a = tsc1.set_stored_data(tsc1a);
            assertTrue(tsc1==tsc1a);
            
            tsc1b=config_store.instance().get_config(tsc1);
            tsc1b = tsc1.set_stored_data(tsc1b);
            assertTrue(tsc1==tsc1b);
            
            config_store.instance().clear_config(tsc,'-file')
            assertFalse(exist(config_file,'file')==2);
        end
        
        function test_set_restore_fields(this)
            % set up
            tsc = some_test_class2();            
            config_store.instance().clear_config(tsc)
            
            test_class_name = tsc.class_name;
            
            config_file = fullfile(config_store.instance().config_folder(),[test_class_name ,'.mat']);
            
            if exist(config_file,'file')
                delete(config_file);
            end
            % testing
            config_store.instance().store_config(tsc,'a','new_val');
            
            tsc1 = config_store.instance().get_config(tsc);
            assertEqual('new_val',tsc1.a);
            assertEqual('beee',tsc1.b);
            assertEqual('other_property',tsc1.c);
            
            config_store.instance().store_config(tsc,'b','meee');
            
            tsc1 = config_store.instance().get_config(tsc);
            assertEqual('new_val',tsc1.a);
            assertEqual('meee',tsc1.b);
            assertEqual('other_property',tsc1.c);
            
            config_store.instance().clear_config(tsc)
            tsc1 = config_store.instance().get_config(tsc);
            assertEqual('new_val',tsc1.a);
            assertEqual('meee',tsc1.b);
            assertEqual('other_property',tsc1.c);
            
            config_store.instance().clear_config(tsc)
            
            config_store.instance().store_config(tsc,'c',100);
            
            tsc1 = config_store.instance().get_config(tsc);
            assertEqual('new_val',tsc1.a);
            assertEqual('meee',tsc1.b);
            assertEqual(100,tsc1.c);
            
            config_store.instance().clear_config(tsc,'-file')
            assertFalse(exist(config_file,'file')==2);
            
        end
        function test_restore_some_fields(this)
            % set up
            tsc = some_test_class2();            
            config_store.instance().clear_config(tsc)
            
            test_class_name = tsc.class_name;
            
            config_file = fullfile(config_store.instance().config_folder(),[test_class_name ,'.mat']);
            
            if exist(config_file,'file')
                delete(config_file);
            end
            % testing
            config_store.instance().store_config(tsc,'a','new_val');
            
            a_val = config_store.instance().get_config_field(tsc,'a');
            assertEqual('new_val',a_val);
            
            config_store.instance().store_config(tsc,'b','meee');
            
            [a_val,b_val,c_val] = config_store.instance().get_config_field(tsc,'a','b','c');
            assertEqual('new_val',a_val);
            assertEqual('meee',b_val);
            assertEqual('other_property',c_val);
            
            config_store.instance().clear_config(tsc)
            [b_val,c_val] = config_store.instance().get_config_field(tsc,'b','c','a');
            assertEqual('meee',b_val);
            assertEqual('other_property',c_val);
            
            config_store.instance().clear_config(tsc)
            config_store.instance().store_config(tsc,'c',100);
            
            c_val = config_store.instance().get_config_field(tsc,'c');
            assertEqual(100,c_val);
            %
            config_store.instance().clear_config(tsc,'-file')
            assertFalse(exist(config_file,'file')==2);
            
        end
    end
    
end


