function [out, suite_out] = runtests(varargin)
%runtests Run unit tests
%   runtests runs all the test cases that can be found in the current directory
%   and summarizes the results in the Command Window.
%
%   Test cases can be found in the following places in the current directory:
%
%       * An M-file function whose name starts or ends with "test" or
%         "Test" and that returns no output arguments.
%
%       * An M-file function whose name starts or ends with "test" or
%         "Test" and that contains subfunction tests and uses the
%         initTestSuite script to return a TestSuite object.
%
%       * An M-file defining a subclass of TestCase.
%
%   runtests(dirname) runs all the test cases found in the specified directory.
%
%   runtests(packagename) runs all the test cases found in the specified
%   package. (This option requires R2009a or later).
%
%   runtests(mfilename) runs test cases found in the specified function or class
%   name. The function or class needs to be in the current directory or on the
%   MATLAB path.
%
%   runtests('mfilename:testname') runs the specific test case named 'testname'
%   found in the function or class 'mfilename'.
%
%   runtests('dirname/mfilename:testname') runs the specific test case named
%   'testname' found in the function or class 'mfilename' in the folder
%   'dirname'.
%
%   Multiple directories or file names can be specified by passing multiple
%   names to runtests, as in runtests(name1, name2, ...) or
%   runtests({name1, name2, ...}, ...).
%
%
%   Optional keywords:
%   ------------------
%   runtests(..., '-verbose') displays the name and result, result, and time
%   taken for each test case to the Command Window.
%
%   runtests(..., '-nodisp_skipped') disables printing of detailed information
%    about skipped tests.
%
%   runtests(..., '-logfile', filename) directs the output of runtests to
%   the specified log file instead of to the Command Window.
%
%
%   Output argument(s):
%   -------------------
%   out = runtests(...) returns a logical value that is true if all the
%   tests passed.
%
%   [out, suite] = runtests(...) returns the full set of test suites run by the
%   call to runtests.
%
%
%   -------------------------------
%   Examples
%   -------------------------------
%   Find and run all the test cases in the current directory.
%
%       runtests
%
%   Find and run all the test cases in the current directory. Display more
%   detailed information to the Command Window as the test cases are run.
%
%       runtests -verbose
%
%   Save verbose runtests output to a log file.
%
%       runtests -verbose -logfile my_test_log.txt
%
%   Find and run all the test cases contained in the M-file myfunc.
%
%       runtests myfunc
%
%   Find and run all the test cases contained in the TestCase subclass
%   MyTestCase.
%
%       runtests MyTestCase
%
%   Run the test case named 'testFeature' contained in the M-file myfunc.
%
%       runtests myfunc:testFeature
%
%   Run all the tests in a specific directory.
%
%       runtests c:\Work\MyProject\tests
%
%   Run all the tests in two directories.
%
%       runtests c:\Work\MyProject\tests c:\Work\Book\tests

%   Steven L. Eddins
%   Copyright 2009-2010 The MathWorks, Inc.
%
%   Alex Buts, Toby Perring, Jacob Wilkins
%   2011 - 2025 
%   Various small changes: optional keyword arguments, test locations, display
%   of output to screen etc.


[name_list, verbose, logfile, disp_fail_only] = getInputNames(varargin{:});
if numel(name_list) == 0
    suite = TestSuite.fromPwd();
elseif isscalar(name_list)
    suite = TestSuite.fromName(name_list{1});
else
    suite = TestSuite();
    for k = 1:numel(name_list)
        suite.add(TestSuite.fromName(name_list{k}));
    end
end

if isempty(suite.TestComponents)
    error('xunit:runtests:noTestCasesFound', 'No test cases found.');
end

if isempty(logfile)
    logfile_handle = 1; % File handle corresponding to Command Window
else
    logfile_handle = fopen(logfile, 'w');
    if logfile_handle < 0
        error('xunit:runtests:FileOpenFailed', ...
            'Could not open "%s" for writing.', logfile);
    else
        cleanup = onCleanup(@() fclose(logfile_handle));
    end
end

fprintf(logfile_handle,[ ...
    '======================================================================\n',...
    '**********************************************************************\n',...
    '*** Test suite         : %s\n'], suite.Name);
if ~strcmp(suite.Name, suite.Location)
    fprintf(logfile_handle, ...
        '*** Test suite location: %s\n', suite.Location);
end
fprintf(logfile_handle, ['*** %s\n', ...
    '**********************************************************************\n\n'],...
    datetime('now'));

if verbose
    monitor = VerboseTestRunDisplay(logfile_handle);
else
    monitor = TestRunDisplay(logfile_handle);
end
monitor.disp_fail_only = disp_fail_only;


[did_pass, num_tests_run] = suite.run(monitor);
if did_pass && num_tests_run == 0
    error('xunit:runtests:noTestCasesFound', ...
        'No test cases were run for suite: %s', ...
        suite.Name);
end

if nargout > 0
    out = did_pass;
end
if nargout > 1
    suite_out = suite;
end
end


%-------------------------------------------------------------------------------
function [name_list, verbose, logfile, disp_fail_only] = getInputNames(varargin)
name_list = {};
verbose = false;
logfile = '';
disp_fail_only = false;
k = 1;
while k <= numel(varargin)
    arg = varargin{k};
    if iscell(arg)
        name_list = [name_list; arg];
    elseif ~isempty(arg) && (arg(1) == '-')
        if numel(arg)>1 && strncmpi(arg, '-verbose', numel(arg))
            verbose = true;
        elseif numel(arg)>1 && strncmpi(arg, '-logfile', numel(arg))
            if k == numel(varargin)
                error('xunit:runtests:MissingLogfile', ...
                    'The option -logfile must be followed by a filename.');
            else
                logfile = varargin{k+1};
                k = k + 1;
            end
        elseif numel(arg)>1 && strncmpi(arg, '-nodisp_skipped', numel(arg))
            disp_fail_only = true;
        else
            warning('runtests:unrecognizedOption', 'Unrecognized option: %s', arg);
        end
    else
        name_list{end+1} = arg;
    end
    k = k + 1;
end
end
