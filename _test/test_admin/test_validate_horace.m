classdef test_validate_horace < TestCase
    % Test that the function to read Horace CMakeLists.txt into
    % validate_horace performs as expected.
    
    properties
        root_test_path
        CMakeLists_file
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_validate_horace(varargin)
            if nargin>0
                name = varargin{1};
            else
                name = 'test_validate_horace';
            end
            self = self@TestCase(name);
            
            this_path = fileparts(mfilename('fullpath'));
            self.root_test_path = fullfile(this_path, '_test');
            self.CMakeLists_file = fullfile(this_path, '_test', 'CMakeLists.txt');
        end
        
        %--------------------------------------------------------------------------
        function test_CMakeLists(self)
            % Run all test cases in the provided CMakeLists.txt
            
            run_dir = tmp_dir;  % a folder well away from the tests folders
            [err, names] = run_the_test(self, run_dir);

            names_ref = { ...
                'test_class_1a::testPointer_1a'; ...
                'test_class_1a::testColormapColumns_1a'; ...
                'test_class_2a::testPointer_2a'; ...
                'test_class_2a::testColormapColumns_2a'; ...
                'test_class_3a::testPointer_3a'; ...
                'test_class_3a::testColormapColumns_3a'; ...
                'test_single_func_1a'; ...
                'test_single_func_2a'; ...
                'test_class_1b::testPointer_1b'; ...
                'test_class_1b::testColormapColumns_1b'; ...
                'test_class_2b::testPointer_2b'; ...
                'test_class_2b::testColormapColumns_2b'; ...
                'test_class_1c::testPointer_1c'; ...
                'test_class_1c::testColormapColumns_1c'; ...
                'test_class_2c::testPointer_2c'; ...
                'test_class_2c::testColormapColumns_2c'; ...
                'test_class_3c::testPointer_3c'; ...
                'test_class_3c::testColormapColumns_3c'; ...
                'test_single_func_1c'; ...
                'test_single_func_2c'; ...
                'test_class_1d::testPointer_1d'; ...
                'test_class_1d::testColormapColumns_1d'; ...
                'test_class_2d::testPointer_2d'; ...
                'test_class_2d::testColormapColumns_2d'};
            assertFalse(err)
            assertEqual(names_ref, names)
        end
        
        %--------------------------------------------------------------------------
        function test_allTestClasses_inDir(self)
            % Run all testCase subclasses and test functions in a given
            % directory in root_test_path
            
            run_dir = tmp_dir;  % a folder well away from the tests folders
            [err, names] = run_the_test(self, run_dir, 'test_examples_a');

            names_ref = {...
                'test_class_1a::testPointer_1a'; ...
                'test_class_1a::testColormapColumns_1a'; ...
                'test_class_2a::testPointer_2a'; ...
                'test_class_2a::testColormapColumns_2a'; ...
                'test_class_3a::testPointer_3a'; ...
                'test_class_3a::testColormapColumns_3a'; ...
                'test_single_func_1a'; ...
                'test_single_func_2a'};
            assertFalse(err)
            assertEqual(names_ref, names)
        end
        
        %--------------------------------------------------------------------------
        function test_testClass_inDir(self)
            % Run just one testCase subclass in a given directory in root_test_path
            
            run_dir = tmp_dir;  % a folder well away from the tests folders
            [err, names] = run_the_test(self, run_dir, 'test_examples_c/test_class_2c');

            names_ref = {...
                'test_class_2c::testPointer_2c'; ...
                'test_class_2c::testColormapColumns_2c'};
            assertFalse(err)
            assertEqual(names_ref, names)
        end
        
        %--------------------------------------------------------------------------
        function test_method_in_testClass_inDir(self)
            % Run just one method in one testCase subclass in a given directory
            % in root_test_path
            
            run_dir = tmp_dir;  % a folder well away from the tests folders
            [err, names] = run_the_test(self, run_dir, ...
                'test_examples_b/test_class_2b:testColormapColumns_2b');

            names_ref = {'test_class_2b::testColormapColumns_2b'};
            assertFalse(err)
            assertEqual(names_ref, names)
        end
        
        %--------------------------------------------------------------------------
        function test_three_test_arguments(self)
            % Run just one method in one testCase subclass in a given directory
            % in root_test_path
            
            run_dir = tmp_dir;  % a folder well away from the tests folders
            [err, names] = run_the_test(self, run_dir, ...
                'test_examples_b/test_class_2b:testColormapColumns_2b', ...
                'test_examples_c/test_class_2c', ...
                'test_examples_a');

            names_ref = {'test_class_2b::testColormapColumns_2b'; ...
                'test_class_2c::testPointer_2c'; ...
                'test_class_2c::testColormapColumns_2c'; ...
                'test_class_1a::testPointer_1a'; ...
                'test_class_1a::testColormapColumns_1a'; ...
                'test_class_2a::testPointer_2a'; ...
                'test_class_2a::testColormapColumns_2a'; ...
                'test_class_3a::testPointer_3a'; ...
                'test_class_3a::testColormapColumns_3a'; ...
                'test_single_func_1a'; ...
                'test_single_func_2a'};
            assertFalse(err)
            assertEqual(names_ref, names)
        end
        
        %--------------------------------------------------------------------------
        function test_testClass_inPwd(self)
            % Run just one testCase subclass in a given directory in root_test_path
            
            run_dir = fullfile(self.root_test_path, 'test_examples_d');  % folder where there is a test
            [err, names] = run_the_test(self, run_dir, 'test_class_3d');

            names_ref = {...
                'test_class_3d::testPointer_3d'; ...
                'test_class_3d::testColormapColumns_3d'};
            assertFalse(err)
            assertEqual(names_ref, names)
        end
        
        %--------------------------------------------------------------------------
        function test_method_in_testClass_inPwd(self)
            % Run just one method in one testCase subclass in a given directory
            % in root_test_path
            
            run_dir = fullfile(self.root_test_path, 'test_examples_d');  % folder where there is a test
            [err, names] = run_the_test(self, run_dir, 'test_class_1d:testColormapColumns_1d');

            names_ref = {'test_class_1d::testColormapColumns_1d'};
            assertFalse(err)
            assertEqual(names_ref, names)
        end
        
        
        %--------------------------------------------------------------------------
        %   * >> validate_horace ('dirname')                      %  Run all tests in the named folder.
        %   * >> validate_horace ('dirname/mfilename')            %  Run all tests in the named test suite
        %   * >> validate_horace ('dirname/mfilename:testname')   %  Run one particular test in the named
        %                                                       % test suite in the named folder.
        %   * >> validate_horace (arg1, arg2, ...)                %  Run a sequence of tests, where arg1,
        %                                                       % arg2, arg3,... are each any one of
        %                                                       % the syntaxes above.        %
        %
        % Run tests that are in the present working directory:
        %   >> validate_horace ('mfilename')                    %  Run all tests in the named test suite
        %   >> validate_horace ('mfilename:testname')
        %--------------------------------------------------------------------------
    end
end


%-------------------------------------------------------------------------------
function [out, names] = run_the_test(obj, run_dir, varargin)
% Utility to set up a call to validate_horace.
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
root_test_path = obj.root_test_path;
CMakeLists_file = obj.CMakeLists_file;

cd(run_dir)
if ~isempty(varargin)
    [out, suite] = validate_horace(varargin{:}, '-root_test_path', root_test_path, ...
        '-CMakeLists_file', CMakeLists_file, '-logfile', logfilename);
else
    [out, suite] = validate_horace('-root_test_path', root_test_path, ...
        '-CMakeLists_file', CMakeLists_file, '-logfile', logfilename);
end

% Get TestCase names
names = get_test_case_names(suite);

end

%-------------------------------------------------------------------------------
function names = get_test_case_names (obj)
% Get the names of all TestCase objects in a TestSuite object
names = add_test_case_names (obj, {});
end

%--------------------------------------
function names = add_test_case_names (obj, names)
% Recursively add names of all TestCase objects in a TestSuite object
if isa(obj, 'cell')     % cell array of TestSuite objects
    for i = 1:numel(obj)
        names = add_test_case_names(obj{i}, names);
    end
elseif isa(obj, 'TestSuite')
    for i = 1:numel(obj.TestComponents)
        names = add_test_case_names(obj.TestComponents{i}, names);
    end
elseif isa(obj, 'TestCase')
    names = [names; obj.Name];
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
