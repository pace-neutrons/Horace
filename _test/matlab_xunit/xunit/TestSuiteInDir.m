%TestSuiteInDir Test suite requiring temporary directory change
%   The TestSuiteInDir class defines a test suite that has to be run by first
%   changing to a specified directory.
%
%   The setUp method adds the starting directory to the path and then uses cd to
%   change into the specified directory.  The tearDown method restores the
%   original path and directory.
%
%   TestSuiteInDir methods:
%       TestSuiteInDir  - Constructor
%       gatherTestCases - Add test cases found in the target directory
%
%   See also TestSuite

%   Steven L. Eddins
%   Copyright 2009 The MathWorks, Inc.

classdef TestSuiteInDir < TestSuite & TestComponentInDir
    properties
        % full path to the folder, the test is located in.
        % used by setUp/teadDown methods to put folder on data search
        % path.
        full_test_dir_name;
    end
    
    
    methods
        function self = TestSuiteInDir(testDirectory)
            %TestCaseInDir Constructor
            %   TestCaseInDir(testName, testDirectory) constructs a test case
            %   using the specified name and located in the specified directory.
            self = self@TestComponentInDir(testDirectory);
            
            if strcmp(testDirectory, '.')
                self.Name = pwd;
                self.Location = pwd;
            else
                [pathstr, name] = fileparts(testDirectory);
                self.Name = name;
                self.Location = testDirectory;
            end
            
            
        end
        function setUp(self)
            s = what(self.Location);
            self.full_test_dir_name = s.path;
            addpath(self.full_test_dir_name);
            
        end
        function tearDown(self)
            %tearDown Tear down test fixture
            %   test_component.tearDown() is at the end of the method.  Test
            %   writers can override tearDown if necessary to clean up a test
            %   fixture.
            rmpath(self.full_test_dir_name)
        end
        
        
        function gatherTestCases(self)
            %gatherTestCases Add test cases found in the target directory
            %   suite.gatherTestCases() automaticall finds all the test cases in
            %   the directory specified in the constructor call and adds them to
            %   the suite.
            current_dir = pwd;
            c = onCleanup(@() cd(current_dir));
            
            cd(self.TestDirectory);
            tmp = TestSuite.fromPwd();
            self.TestComponents = tmp.TestComponents;
        end
    end
end
