classdef test_config_classes < TestCase
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

            clob = set_temporary_warning('off','HERBERT:config_store:default_configuration');

            obj.s0_def = get(tgp_test_class);
            obj.s1_def = get(tgp_test_class1);
            obj.s2_def = get(tgp_test_class2);

        end

        function obj = test_getstruct(obj)
            config_store.instance().clear_config(tgp_test_class2,'-files');
            clob = set_temporary_warning('off','HERBERT:config_store:default_configuration');

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
            clob = set_temporary_warning('off','HERBERT:config_store:default_configuration');

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
            clob = set_temporary_warning('off','HERBERT:config_store:default_configuration');

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

        function obj = test_set_tests(obj)
            % Use presence or otherwise of TestCaseWithSave as a proxy for xunit tests on
            clob = set_temporary_config_options(hor_config);
            % Tests should be found as we are currently in a test suite
            found_on_entry = ~isempty(which('TestCaseWithSave.m'));
            assertTrue(found_on_entry);

            % Turn off tests
            set(hor_config,'init_tests',0,'-buffer');
            found_when_init_tests_off = ~isempty(which('TestCaseWithSave.m'));

            % Turn tests back on
            set(hor_config,'init_tests',1,'-buffer');
            found_when_init_tests_on = ~isempty(which('TestCaseWithSave.m'));

            % Can only use assertTrue, assertFalse etc when tests are on
            assertFalse(found_when_init_tests_off,' folder was not removed from search path properly');
            assertTrue(found_when_init_tests_on);
        end
        function test_unsaveable_recovered_from_store(~)
            clWarn = set_temporary_warning('off', ...
                'HERBERT:test_warning','HERBERT:config_store:default_configuration');
            cf = config_base_tester();
            config_class_file = fullfile(cf.config_folder,'config_base_tester.mat');
            config_store.instance.clear_config(config_base_tester,'-file');
            assertFalse(is_file(config_class_file));
            warning('HERBERT:test_warning','this is to set warning to defined state')

            val = config_store.instance().get_value('config_base_tester','unsaveable_property');
            assertEqual(val,'abra_cadabra');
            [~,lv] = lastwarn;
            assertEqual(lv,'HERBERT:config_store:default_configuration')
        end


        function test_unsaveable_sets_gets_clears(~)
            clWarn = set_temporary_warning('off', ...
                'HERBERT:test_warning','HERBERT:config_store:default_configuration');
            cf = config_base_tester();
            config_class_file = fullfile(cf.config_folder,'config_base_tester.mat');
            config_store.instance.clear_config(config_base_tester,'-file');
            assertFalse(is_file(config_class_file));

            warning('HERBERT:test_warning','this is to check if no other warning was issued')
            % As we have deleted config from memory and file.
            % this generates the warning if defaults were used (first
            % configuration) as the class is indeed configured for the
            % first time, but nothing is changed in file. This is probably
            % expected behaviour.
            cf.unsaveable_property = 'ha_ha_ha';
            % but nothing have been saved
            assertFalse(is_file(config_class_file));
            cf.my_prop = 'AAA';

            assertEqual(cf.unsaveable_property,'ha_ha_ha');
            assertEqual(cf.my_prop,'AAA');

            config_store.instance.clear_config(config_base_tester);
            assertTrue(is_file(config_class_file));

            cf = config_base_tester();
            assertEqual(cf.unsaveable_property,'abra_cadabra');
            assertEqual(cf.my_prop,'AAA');

            [~,lv] = lastwarn;
            assertEqual(lv,'HERBERT:config_store:default_configuration')
        end

        function test_unsaveable_property_works_with_no_warning(~)
            clWarn = set_temporary_warning('off', ...
                'HERBERT:test_warning','HERBERT:config_store:default_configuration');
            cf = config_base_tester();
            config_class_file = fullfile(cf.config_folder,'config_base_tester.mat');
            if ~isfile(config_class_file)
                cf.my_prop = 'something'; % store modified configuration
            end
            assertTrue(isfile(config_class_file))
            warning('HERBERT:test_warning','this is to check if no other warning was issued')

            assertEqual(cf.unsaveable_property,'abra_cadabra');
            [~,lv] = lastwarn;
            assertEqual(lv,'HERBERT:test_warning')
        end
    end
end
