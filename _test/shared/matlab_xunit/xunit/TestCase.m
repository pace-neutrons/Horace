%TestCase Class defining interface for test cases
%   The TestCase class defines an individual test case.
%
%   Normally a test writer will create their own test class that is a subclass
%   of TestCase.  Each instance of the TestCase subclass that gets created will
%   be associated with a single test method.
%
%   If a test fixture is needed, override the setUp() and tearDown() methods.
%
%   TestSuite(subclass_name), where subclass_name is the name of a TestCase
%   subclass, creates a test suite containing one TestCase instance per test
%   method contained in the subclass.
%
%   A simpler test-writing alternative to use subfunction-based M-file tests.
%   See the MATLAB xUnit documentation.
%
%   TestCase methods:
%       TestCase - Constructor
%       run      - Execute the test case
%
%   TestCase properties:
%       Location - Location of M-file containing the test case
%       Name     - Name of test case
%
%   See also TestComponent, TestSuite

%   Steven L. Eddins
%   Modified J. Wilkins 19-01-2021
%   Copyright 2008-2010 The MathWorks, Inc.

classdef TestCase < TestComponent
    
    properties
        MethodName
    end
    
    methods
        function self = TestCase(testMethod)
            %TestCase Constructor
            %   TestCase(methodName) constructs a TestCase object using the
            %   specified testMethod (a string).
            
            self.MethodName = testMethod;
            self.Name = testMethod;
            self.Location = which(class(self));
        end
        
        function [did_pass,num_tests_run] = run(self, monitor,num_tests_run)
            %run Execute the test case
            %    test_case.run(monitor) calls the TestCase object's setUp()
            %    method, then the test method, then the tearDown() method.
            %    observer is a TestRunObserver object.  The testStarted(),
            %    testFailure(), testError(), and testFinished() methods of
            %    observer are called at the appropriate times.  monitor is a
            %    TestRunMonitor object.  Typically it is either a TestRunLogger
            %    subclass or a CommandWindowTestRunDisplay subclass.
            %
            %    test_case.run() automatically uses a
            %    CommandWindowTestRunDisplay object in order to print test
            %    suite execution information to the Command Window.
            
            if nargin < 2
                monitor = CommandWindowTestRunDisplay();
            end
            if nargin< 3
                num_tests_run = 0;
            end
            
            did_pass = self.passed;
            monitor.testComponentStarted(self);
            
            try
                self.setUp();
                if ischar(self.MethodName)
                    f = str2func(self.MethodName);
                    name2print  = self.Name;
                elseif ishandle(self.MethodName)
                    f = self.MethodName;
                    name2print  = func2str(self.MethodName);
                else
                    error('TestCase:invalid_argument',...
                        'Unknown Method name type');
                end
                if self.print_running_tests
                    tStart = tic;
                    fprintf('**************************************************** \n');
                    fprintf('************  starting test: %s\n',name2print);
                    fprintf('**************************************************** \n');
                end
                
                try
                    % Call the test method.
                    f(self);
                catch failureException
                    if (strcmp(failureException.identifier,'testSkipped:testSkipped'))
                        monitor.testCaseSkip(self, failureException);
                        did_pass = self.skipped;
                    else
                        monitor.testCaseFailure(self, failureException);
                        did_pass = self.failed;
                    end
                end
                if self.print_running_tests
                    tEnd = toc(tStart);
                    fprintf('**************************************************** \n');
                    fprintf('************  Test:  %s completed in %5.1fsec\n',...
                        name2print,tEnd);
                    fprintf('**************************************************** \n');
                end
                
                
                self.tearDown();
                
            catch errorException
                monitor.testCaseError(self, errorException);
                did_pass = self.failed;
            end
            
            monitor.testComponentFinished(self, did_pass);
            num_tests_run = num_tests_run+1;
        end
        
        function num = numTestCases(self)
            num = 1;
        end
        
        function print(self, numLeadingBlanks)
            if nargin < 2
                numLeadingBlanks = 0;
            end
            fprintf('%s%s\n', blanks(numLeadingBlanks), self.Name);
        end
        
    end
    
end
