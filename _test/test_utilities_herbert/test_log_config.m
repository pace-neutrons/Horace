classdef test_log_config< TestCase

    properties
    end
    methods
        %
        function this=test_log_config(varargin)
            if nargin == 0
                name = 'test_log_config';
            else
                name = varargin{1};
            end
            this = this@TestCase(name);
        end
        % tests themself
        function test_all_split_log_ratios_warn_small(~)
            clWa = set_temporary_warning('off', ...
                'HORACE:clear_test_warn','LOG_CONFIG:setting_log_split_ratio');
            tc = log_config;
            % do not store test results in file for further usage
            tc.saveable = false;
            all_prop = tc.get_storage_field_names;
            % remove log time as it is tested separately;
            all_prop = all_prop(2:end);
            for i = 1:numel(all_prop)
                warning('HORACE:clear_test_warn','clear possible warnings');
                tc.(all_prop{i}) = 0.1;
                assertEqual(tc.(all_prop{i}),1, ...
                    sprintf(' Property %s has not been set correctly\n',all_prop{i}))
                [mess,lw] = lastwarn;
                assertEqual(lw,'LOG_CONFIG:setting_log_split_ratio')
                assertTrue(contains(mess,all_prop{i}))
            end
            % clear changes to log_config from memory not to destroy
            % possible autoconfigurations
            config_store.instance().clear_config(tc);
        end


        function test_all_split_log_ratios_settable(~)
            tc = log_config;
            % do not store test results
            tc.saveable = false;
            all_prop = tc.get_storage_field_names;
            % remove log time as it is tested separately;
            all_prop = all_prop(2:end);
            for i = 1:numel(all_prop)
                tc.(all_prop{i}) = 100;
                assertEqual(tc.(all_prop{i}),100, ...
                    sprintf(' Property %s has not been set correctly\n',all_prop{i}))
            end
            tc.info_log_print_time = 60;
            assertEqual(tc.info_log_print_time,60, ...
                'can not store/restore info_log_print_time')
            % clear changes to log_config from memory not to destroy
            % possible autoconfigurations
            config_store.instance().clear_config(tc);
        end
        function test_auto_logging(~)
            % test depends on code execution time and expect pause last 1
            % second +-10%. Sometimes on some machines this would not
            % happen (Windows suddently decides not to give job sufficient
            % time to perform), so the test may fail
            tc = log_config();
            clOb = set_temporary_config_options(tc,'info_log_print_time',2);
            tc = tc.init_adaptive_logging();
            pause(1);
            [tc,time] = tc.adapt_logging(1);
            assertEqualToTol(time,1,'tol',[0.1,0.1]);
            slr = tc.info_log_split_ratio;
            assertEqual(slr,2);
        end
        function test_info_log_print_time(~)
            tc = log_config();
            tc.info_log_print_time = 30;
            assertEqual(tc.info_log_print_time,30);
        end
        function test_info_log_split_ratio(~)
            tc = log_config();
            assertEqual(tc.info_log_split_ratio,1);
        end

    end
end

