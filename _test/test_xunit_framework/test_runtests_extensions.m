classdef test_runtests_extensions < TestCase
    % Tests that various test location syntax cases are correctly parsed by
    % runtests.
    % Some of these were added for ISIS, others were already in the original
    % runtests but tests are added here for integrity checking.
    
    properties
        test_examples_a
        test_examples_b
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_runtests_extensions(varargin)
            if nargin>0
                name = varargin{1};
            else
                name = 'test_runtests_extensions';                
            end            
            self = self@TestCase(name);    
            
            p = fileparts(mfilename('fullpath'));
            self.test_examples_a = fullfile(p, 'test_examples_a');
            self.test_examples_b = fullfile(p, 'test_examples_b');
        end
        
        %--------------------------------------------------------------------------
        function test_singleFunction_inPwd(self)
            % Test case is a function in the directory runtests is invoked in.
            
            % Setup
            tests_location = self.test_examples_a;
            test_full_filename = fullfile(tests_location, 'test_single_func_1.m');

            % Run test
            [out, suite] = run_the_test(tests_location, 'test_single_func_1');
            
            % Test output
            assertTrue(out)
            assertEqual(class(suite), 'TestSuite')
            assertEqual(suite.Location, test_full_filename)
            assertEqual(suite.TestComponents{1}.Name, 'test_single_func_1')
        end

        %--------------------------------------------------------------------------
        function test_singleFunction_notInPwd(self)
            % Test case is a function not in the directory runtests is invoked in.
            
            % Setup
            tests_location = self.test_examples_a;
            test_full_filename = fullfile(tests_location, 'test_single_func_1.m');
            
            % Run test
            assertFalse(isequal(pwd, tests_location))
            [out, suite] = run_the_test(pwd, [tests_location, '/test_single_func_1']);

            % Test output
            assertTrue(out)
            assertEqual(class(suite), 'TestSuiteInDir')
            assertEqual(class(suite.TestComponents{1}), 'TestSuite')
            sub_suite = suite.TestComponents{1};
            assertEqual(sub_suite.Location, test_full_filename)
            assertEqual(sub_suite.TestComponents{1}.Name, 'test_single_func_1')
        end

        %--------------------------------------------------------------------------
        function test_testClass_inPwd(self)
            % Test case is a TestCase sub-class in the directory runtests is invoked in.

            % Setup
            tests_location = self.test_examples_a;
            test_full_filename = fullfile(tests_location, 'test_class_1.m');

            % Run test
            [out, suite] = run_the_test(tests_location, 'test_class_1');
            
            % Test output
            assertTrue(out)
            assertEqual(class(suite), 'TestSuite')
            assertEqual(suite.Location, test_full_filename)
            assertEqual(suite.TestComponents{1}.Name, 'test_class_1::testPointer_1')
            assertEqual(suite.TestComponents{2}.Name, 'test_class_1::testColormapColumns_1')
        end

        %--------------------------------------------------------------------------
        function test_testClass_notInPwd(self)
            % Test case is a TestCase sub-class not in the directory runtests is
            % invoked in.
            
            % Setup
            tests_location = self.test_examples_a;
            test_full_filename = fullfile(tests_location, 'test_class_1.m');
            
            % Run test
            assertFalse(isequal(pwd, tests_location))
            [out, suite] = run_the_test(pwd, [tests_location, '/test_class_1']);

            % Test output
            assertTrue(out)
            assertEqual(class(suite), 'TestSuiteInDir')
            assertEqual(class(suite.TestComponents{1}), 'TestSuite')
            sub_suite = suite.TestComponents{1};
            assertEqual(sub_suite.Location, test_full_filename)
            assertEqual(sub_suite.TestComponents{1}.Name, 'test_class_1::testPointer_1')
            assertEqual(sub_suite.TestComponents{2}.Name, 'test_class_1::testColormapColumns_1')
        end

        %--------------------------------------------------------------------------
        function test_testClass_singleMethod_inPwd(self)
            % Test case is a single method of a TestCase sub-class in the
            % directory runtests is invoked in.
            
            % Setup
            tests_location = self.test_examples_a;
            test_full_filename = fullfile(tests_location, 'test_class_1.m');

            % Run test
            [out, suite] = run_the_test(tests_location, ...
                'test_class_1:testColormapColumns_1');

            % Test output
            assertTrue(out)
            assertEqual(class(suite), 'TestSuite')
            assertEqual(suite.Location, test_full_filename)
            assertEqual(suite.TestComponents{1}.Name, 'test_class_1::testColormapColumns_1')
        end

        %--------------------------------------------------------------------------
        function test_testClass_singleMethod_notInPwd(self)
            % Test case is a single method of a TestCase sub-class not in the
            % directory runtests is invoked in.
            
            % Setup
            tests_location = self.test_examples_a;
            test_full_filename = fullfile(tests_location, 'test_class_1.m');
            
            % Run test
            assertFalse(isequal(pwd, tests_location))
            [out, suite] = run_the_test(pwd, ...
                [tests_location, '/test_class_1:testColormapColumns_1']);
            
            % Test output
            assertTrue(out)
            assertEqual(class(suite), 'TestSuiteInDir')
            assertEqual(class(suite.TestComponents{1}), 'TestSuite')
            sub_suite = suite.TestComponents{1};
            assertEqual(sub_suite.Location, test_full_filename)
            assertEqual(sub_suite.TestComponents{1}.Name, 'test_class_1::testColormapColumns_1')
        end

        %--------------------------------------------------------------------------
        function test_allTests_inPwd(self)
            % All tests (test functions and TestCase sub-classes) in the
            % directory runtests is invoked in.
            
            % Setup
            tests_location = self.test_examples_a;
            test_full_filename{1} = fullfile(tests_location, 'test_class_1.m');
            test_full_filename{2} = fullfile(tests_location, 'test_class_2.m');
            test_full_filename{3} = fullfile(tests_location, 'test_class_3.m');
            test_full_filename{4} = fullfile(tests_location, 'test_single_func_1.m');
            test_full_filename{5} = fullfile(tests_location, 'test_single_func_2.m');
            
            % Run test
            [out, suite] = run_the_test(tests_location);
            
            % Test output
            assertTrue(out)
            assertEqual(class(suite), 'TestSuite')
            for i=1:5
                assertEqual(class(suite.TestComponents{i}), 'TestSuite')
                assertEqual(suite.TestComponents{i}.Location, test_full_filename{i})
            end
            % Dip into two of the test sub-suites to check the individual tests
            sub_suite = suite.TestComponents{3};
            assertEqual(sub_suite.TestComponents{1}.Name, 'test_class_3::testPointer_3')
            assertEqual(sub_suite.TestComponents{2}.Name, 'test_class_3::testColormapColumns_3')
            sub_suite = suite.TestComponents{4};
            assertEqual(sub_suite.TestComponents{1}.Name, 'test_single_func_1')
        end
        
        %--------------------------------------------------------------------------
        function test_allTests_notInPwd(self)
            % All tests (test functions and TestCase sub-classes) in a directory
            % that is not the directory runtests is invoked in.
            
            % Setup
            tests_location = self.test_examples_a;
            test_full_filename{1} = fullfile(tests_location, 'test_class_1.m');
            test_full_filename{2} = fullfile(tests_location, 'test_class_2.m');
            test_full_filename{3} = fullfile(tests_location, 'test_class_3.m');
            test_full_filename{4} = fullfile(tests_location, 'test_single_func_1.m');
            test_full_filename{5} = fullfile(tests_location, 'test_single_func_2.m');
            
            % Run test
            assertFalse(isequal(pwd, tests_location))
            [out, suite] = run_the_test(pwd, tests_location);
            
            % Test output
            assertTrue(out)
            assertEqual(class(suite), 'TestSuiteInDir')
            for i=1:5
                assertEqual(class(suite.TestComponents{i}), 'TestSuite')
                assertEqual(suite.TestComponents{i}.Location, test_full_filename{i})
            end
            % Dip into two of the test sub-suites to check the individual tests
            sub_suite = suite.TestComponents{3};
            assertEqual(sub_suite.TestComponents{1}.Name, 'test_class_3::testPointer_3')
            assertEqual(sub_suite.TestComponents{2}.Name, 'test_class_3::testColormapColumns_3')
            sub_suite = suite.TestComponents{4};
            assertEqual(sub_suite.TestComponents{1}.Name, 'test_single_func_1')
        end
        
        %--------------------------------------------------------------------------
        function test_multipleArgs_notInPwd(self)
            % Multiple test arguments to runtests, some tests in the directory
            % from which it is invoked, some not.
            % Tests the multiple arguments capability.
            
            % Setup
            tests_location_a = self.test_examples_a;
            tests_location_b = self.test_examples_b;

            
            % Run the test. It runs:
            % (1) a TestCase sub-class in a directory that is not the run directory
            %     and a single test function in the run directory. These two
            %     arguments are enclosed in a cell-array.
            %     The cell array will be resolved into the two separate
            %     arguments by runtests.
            % (2) A single argument that invokes all the tests in the run directory.
            %
            % The effect should be the same as the three arguments run in
            % succession.

            assertFalse(isequal(tests_location_a, tests_location_b))
            [out, suite] = run_the_test(tests_location_a, ...
                {[tests_location_b,'/test_class_1b'], 'test_single_func_1'}, ...
                tests_location_a);
            
            % Test output
            assertTrue(out)
            assertEqual(class(suite), 'TestSuite')
            
            % - first test argument breakdown
            sub_suite = suite.TestComponents{1};
            assertEqual(class(sub_suite), 'TestSuiteInDir')
            assertEqual(class(sub_suite.TestComponents{1}), 'TestSuite')
            sub_sub_suite = sub_suite.TestComponents{1};
            assertEqual(sub_sub_suite.Location, fullfile(tests_location_b, 'test_class_1b.m'))
            assertEqual(sub_sub_suite.TestComponents{1}.Name, 'test_class_1b::testPointer_1b')
            assertEqual(sub_sub_suite.TestComponents{2}.Name, 'test_class_1b::testColormapColumns_1b')           
            
            % - second test argument breakdown
            sub_suite = suite.TestComponents{2};
            assertEqual(class(sub_suite), 'TestSuite')
            assertEqual(sub_suite.Location, fullfile(tests_location_a, 'test_single_func_1.m'))
            assertEqual(sub_suite.TestComponents{1}.Name, 'test_single_func_1')
            
            % - third test argument breakdown
            test_full_filename{1} = fullfile(tests_location_a, 'test_class_1.m');
            test_full_filename{2} = fullfile(tests_location_a, 'test_class_2.m');
            test_full_filename{3} = fullfile(tests_location_a, 'test_class_3.m');
            test_full_filename{4} = fullfile(tests_location_a, 'test_single_func_1.m');
            test_full_filename{5} = fullfile(tests_location_a, 'test_single_func_2.m');
            
            sub_suite = suite.TestComponents{3};
            assertEqual(class(sub_suite), 'TestSuiteInDir')
            for i=1:5
                assertEqual(class(sub_suite.TestComponents{i}), 'TestSuite')
                assertEqual(sub_suite.TestComponents{i}.Location, test_full_filename{i})
            end
            % Dip into two of the test sub-suites to check the individual tests
            sub_sub_suite = sub_suite.TestComponents{3};
            assertEqual(sub_sub_suite.TestComponents{1}.Name, 'test_class_3::testPointer_3')
            assertEqual(sub_sub_suite.TestComponents{2}.Name, 'test_class_3::testColormapColumns_3')
            sub_sub_suite = sub_suite.TestComponents{4};
            assertEqual(sub_sub_suite.TestComponents{1}.Name, 'test_single_func_1')
        end
        
        %--------------------------------------------------------------------------
    end
end


%-------------------------------------------------------------------------------
function [out, suite] = run_the_test(run_dir, varargin)
% Utility to set up a call to runtests.
% Moves to run_dir, runs runtests with input arguments varargin{:}, and then
% returns to what was the working directory on input.

curr_dir = pwd;

% Construct the name of a temporary logfile to hold output from this invocation of
% runtests. The temporary logfile will be deleted at the end of this test. This
% is to separate output from this test from the output of the call to runtests
% that is invoking this test, which we may want to examine on the command screen.
logfilename = fullfile(tmp_dir, ['tmp_logfile_', str_random(12), '.txt']);

% On exit or failure, return to original folder and delete the temporary logfile
cleanupObj = onCleanup(@()cleanup(curr_dir, logfilename));

% Run the test
cd(run_dir)
if ~isempty(varargin)
    [out, suite] = runtests(varargin{:}, '-logfile', logfilename);
else
    [out, suite] = runtests('-logfile', logfilename);
end

end

%-------------------------------------------------------------------------------
function cleanup(folder, file)
% Utility to cleanup after a test
% Set the pwd and delete a file, if the name is passed and the file is present
cd(folder)
if nargin>1 && exist(file,'file')==2
    delete(file)
end
end
