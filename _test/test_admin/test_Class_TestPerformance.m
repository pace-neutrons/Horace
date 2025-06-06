classdef test_Class_TestPerformance< TestCase
    % The test verifies TestPerformance class operations.
    %
    % $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
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
        function test_inheritance_with_load_results(this)
            test_res_name = 'TestPerformanceChildTestHelper_PerfRez.xml';
            this_folder = fileparts(mfilename('fullpath'));
            perf_test_source  = fullfile(this_folder,test_res_name);
            per_test_working = fullfile(tmp_dir,test_res_name);
            copyfile(perf_test_source,per_test_working,'f');
            clob = onCleanup(@()delete(per_test_working));
            tc = TestPerformanceChildTestHelper('TestPerformanceChildTestHelper',per_test_working);

            assertEqual(tc.test_results_file,per_test_working)
            assertTrue(is_file(tc.test_results_file));

            delete(tc.test_results_file);

            tc.fake_test_method()

            assertTrue(is_file(tc.test_results_file));
        end


    end
end
