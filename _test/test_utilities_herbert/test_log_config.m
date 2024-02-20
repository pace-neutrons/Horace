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
        function test_auto_logging(~)
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
            hc = hor_config;
            tc = log_config();
            assertEqual(tc.info_log_split_ratio,hc.fb_scale_factor);
        end
        
    end
end

