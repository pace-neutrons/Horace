function [out,suite_out] = runtests(varargin)
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
%   found in the function or class 'name'.
%
%   Multiple directories or file names can be specified by passing multiple
%   names to runtests, as in runtests(name1, name2, ...) or
%   runtests({name1, name2, ...}, ...)
%
%   runtests(..., '-verbose') displays the name and result, result, and time
%   taken for each test case to the Command Window.
%
%   runtests(..., '-logfile', filename) directs the output of runtests to
%   the specified log file instead of to the Command Window.
%
%   out = runtests(...) returns a logical value that is true if all the
%   tests passed.
%
%   -nodisp_skipped  the key disables printing of the detailed information
%                    about skipped tests
%
%   Examples
%   --------
%   Find and run all the test cases in the current directory.
%
%       runtests
%
%   Find and run all the test cases in the current directory. Display more
%   detailed information to the Command Window as the test cases are run.
%
%       runtests -verbose
%  %
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

[ok,mess,display_fail_only,argi] = parse_char_options(varargin,{'-nodisp_skipped'});
if ~ok
    error('HERBERT:runtests:invalid_argument',mess);
end
verbose = false;
logfile = '';
if nargin < 1
    suite = TestSuite.fromPwd();
else
    [name_list, verbose, logfile] = getInputNames(argi{:});
    if numel(name_list) == 0
        suite = TestSuite.fromPwd();
    elseif isscalar(name_list)
        if iscell(name_list{1})
            nml = name_list{1};
            suite = TestSuite.fromName(nml{2},nml{1});
        else
            suite = TestSuite.fromName(name_list{1});
        end
    else
        suite = TestSuite();
        for k = 1:numel(name_list)
            if iscell(name_list{k})
                nml = name_list{k};
                suite.add(TestSuite.fromName(nml{2},nml{1}));
            else
                suite.add(TestSuite.fromName(name_list{k}));
            end
        end
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
if display_fail_only %
    monitor.disp_fail_only = true;
end

[did_pass,num_tests_run] = suite.run(monitor);
if did_pass && num_tests_run == 0
    error('xunit:runtests:noTestCasesFound', ...
        'No test cases were run for suite: %s', ...
        suite.Name);
end

if nargout>0
    out = did_pass;
end
if nargout>1
    suite_out = suite;
end
end

function yes = contains_full_win_path(ddot_ind)
% helper function to identify from presense of : signe that the path is the
% full windows path. The dot positions are found by strfind(path,':')
% function.
yes =  ispc && (isscalar(ddot_ind)) && (ddot_ind(1) == 2) ;
end

function [name_list, verbose, logfile] = getInputNames(varargin)
name_list = {};
verbose = false;
logfile = '';
k = 1;
while k <= numel(varargin)
    arg = varargin{k};
    if iscell(arg)
        name_list = [name_list; arg];
    elseif ~isempty(arg) && (arg(1) == '-')
        if strcmp(arg, '-verbose')
            verbose = true;
        elseif strcmp(arg, '-logfile')
            if k == numel(varargin)
                error('xunit:runtests:MissingLogfile', ...
                    'The option -logfile must be followed by a filename.');
            else
                logfile = varargin{k+1};
                k = k + 1;
            end
        else
            warning('runtests:unrecognizedOption', 'Unrecognized option: %s', arg);
        end
    else
        if exist(arg,'dir') == 7
            name_list{end+1} = arg;
        else
            ddot_ind = strfind(arg,':');
            if isempty(ddot_ind) || ~ispc || contains_full_win_path(ddot_ind)
                [test_folder,test_name] = fileparts(arg);
            else
                test_folder = '';
                test_name = arg;
            end
            if isempty(test_folder)
                name_list{end+1} = test_name;
            else
                name_list{end+1} = {test_folder,test_name};
            end
        end
    end
    k = k + 1;
end
end