classdef test_TestPerformance < TestCase
    properties
        this_path;
    end
    
    methods
        function self = test_TestPerformance(name)
            if nargin<1
                name = 'test_Performance';
            end
            self = self@TestCase(name);
            self.this_path = fileparts(mfilename('fullpath'));
        end
        %
        function test_got_reference_data(obj)
            tc = pTestPerformanceTester(fullfile(obj.this_path,'TestPerformanceTester_PerfRez.xml'));
            res = tc.perf_data;
            fn = fieldnames(res);
            assertEqual(numel(fn),19);
        end
        %
        function test_got_empy_data_from_tmp_folder(~)
            % creates perf file in the tmp folder
            tc = pTestPerformanceTester('TestSome_PerfRez.xml');
            trf = tc.test_results_file;
            assertFalse(is_file(trf));
            res = tc.knownPerformance('gen_sqw');
            assertTrue(isempty(res));
            % empty data exist
            res = tc.perf_data;
            assertTrue(isstruct(res));
            fieldname = [getComputerName(),'_','pTestPerformanceTester'];
            assertTrue(isfield(res,fieldname));
            if is_file(trf)
                delete(trf);
            end
        end
        %
        function test_suite_name_is_computer_name_and_test_class_name(~)
            tc = pTestPerformanceTester();
            name = tc.build_test_suite_name('SomeName');
            assertEqual(name,[getComputerName(),'_','SomeName']);
        end
        function test_default_test_name(~)
            tc = pTestPerformanceTester();
            name = tc.default_PerfTest_fname(mfilename('fullpath'));
            [fp,fn,fe] = fileparts(name);
            assertEqual(fp,fileparts(mfilename('fullpath')));
            assertEqual(fn,'test_TestPerformance_PerfRez');
            assertEqual(fe,'.xml');
        end
        
        %
        function test_empty_results(~)
            tc = pTestPerformanceTester();
            res = tc.knownPerformance('some_gen_sqw');
            assertTrue(isempty(res));
        end
        
        %
        function test_wrong_perf_name(~)
            tc = pTestPerformanceTester();
            try
                tc.knownPerformance('missing_perf_test');
                assertTrue(false,'This call should throw invalid_argument exception')
            catch ERR
                if ~strcmp(ERR.identifier,'HERBERT:TestPerformance:invalid_argument')
                    rethrow(ERR);
                end
            end
        end
        %
        function test_no_known_perf_name(~)
            tc = pTestPerformanceTester();
            try
                tc.knownPerformance();
                assertTrue(false,'This call should throw invalid_argument exception')
            catch ERR
                if ~strcmp(ERR.identifier,'HERBERT:TestPerformance:invalid_argument')
                    rethrow(ERR);
                end
            end
        end
    end
end
