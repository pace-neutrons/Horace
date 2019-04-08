classdef test_Class_TestPerformance< TestCase
    % The test verifies TestPerformance class operations.
    %
    % $Revision:: 830 ($Date:: 2019-04-08 16:16:02 +0100 (Mon, 8 Apr 2019) $)
    %
    properties
    end
    methods
        %
        function this=test_Class_TestPerformance(varargin)
            if nargin>0
                name = varargin{1};
            else
                name = mfilename('class');
            end
            this = this@TestCase(name);
        end
        function test_constructor(this)
            tc = TestPerformance();
            
            time = tic();
            sum = 0;
            for i=1:100
                sum = sum+i;
            end
            
            tc.assertPerformance(time,'test_constructor_operations',...
                'this is not a performance test itself but the test of performance test operational');
        end
        function test_inheritance(this)
            tc = TestPerformanceChildTestHelper();
            
            if exist(tc.test_results_file,'file') == 2
                delete(tc.test_results_file);
            end
            
            tc.fake_test_method()
            assertEqual(exist(tc.test_results_file,'file'),2);
        end
        
        
    end
end

