function [herbert_tests, herbert_system_tests, horace_tests, horace_system_tests] = ...
    validate_horace_read_CMakeLists (CMakeLists_file)
% Extract all tests from CMakeLists.txt in the input folder name that are in one
% of the four CMake variables:
%    - HERBERT_TESTS         (Herbert code unit tests)
%    - HERBERT_SYSTEM_TESTS  (Herbert code system tests)
%    - HORACE_TESTS          (Horace code unit tests)
%    - HORACE_SYSTEM_TESTS   (Horace code system tests)
%
% Input:
% ------
%   CMakeLists_path     Path to the folder containing the CMakeLists.txt file
%                       that is to be read. This must define the four variables
%                       above.
%
%                       See CMakeLists.txt in the root tests folder in the
%                       Horace installation <Horace_root>/_test for an example.
%
%                       Note:
%                       - A given test should only appear in one of the variables.
%                        Later filtering of tests on the basis of being herbert,
%                        horace or system tests may otherwise result in
%                        unexpected tests being run.
%                       - Do not put tests in any other variables in
%                        CMakeLists.txt, because they will not be returned by
%                        this function.
%
% Output:
% -------
%   herbert_tests       Cell array of character vectors with the tests in the
%                       CMake variable HERBERT_TESTS. (Row vector)
%
%   herbert_system_tests Cell array of character vectors with the tests in the
%                       CMake variable HERBERT_SYSTEM_TESTS. (Row vector)
%
%   horace_tests        Cell array of character vectors with the tests in the
%                       CMake variable HORACE_TESTS. (Row vector)
%
%   horace_system_tests Cell array of character vectors with the tests in the
%                       CMake variable HORACE_SYSTEM_TESTS. (Row vector)
%
%
% EXAMPLE of CMakeLists.TXt
%   The opening lines in CMakeLists.txt could be:
%
%         set(HERBERT_TESTS
%             "test_admin"
%             "test_data_loaders"
%                 :
%             "test_mpi_wrappers"
%         )
% 
%         set(HERBERT_SYSTEM_TESTS
%             "test_mpi/test_ParpoolMPI_Framework"
%                 :
%             "test_mpi/test_job_dispatcher_slurm"
%         )
% 
%         set(HORACE_TESTS
%             "test_algorithms"
%             "test_ascii_column_data"
%                 :
%             "test_multifit"
%         )
% 
%         set(HORACE_SYSTEM_TESTS
%             "test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_herbert"
%                 :
%             "test_TF_refine_crystal"
%         )
%                 :

txt = read_text_file_as_string (CMakeLists_file);
herbert_tests = get_tests_from_string (txt, 'HERBERT_TESTS');
herbert_system_tests = get_tests_from_string (txt, 'HERBERT_SYSTEM_TESTS');
horace_tests = get_tests_from_string (txt, 'HORACE_TESTS');
horace_system_tests = get_tests_from_string (txt, 'HORACE_SYSTEM_TESTS');

system_tests = [herbert_system_tests, horace_system_tests];


%-------------------------------------------------------------------------------
function txt = read_text_file_as_string (filename)
% Read text file as a single character vector

if is_file(filename)
    fid = fopen(filename, 'rt');
    if fid<0
        error('HORACE:validate', 'Unable to open file %s', filename)
    end
    cleanupObj = onCleanup(@()fclose(fid));
else
    error('HORACE:validate', 'File not found: %s', filename)
end

try
    txt = fread(fid,'*char')';  % read file as one long character vector
catch exception
    fclose(fid);
    throw(exception);
end


%-------------------------------------------------------------------------------
function out = get_tests_from_string (txt, var)
% If <var> is e.g. 'TEST_DIRECTORIES_HERBERT' or 'TEST_DIRECTORIES_HORACE',
% find occurences of text that contain any characters sandwiched between:
%       'set(<var>'  or  'SET(<var>'
% and:
%       ')'

% Allow any amount of whitesapce (including line feed, carriage return) between
% 'set', '(', and <var>, with at least one whitespace character after <var> to
% demarcate it from following characters
prefix = ['(?<=(SET|set)\s*\(\s*', var, '\s+)'];
% Contents are any characters excluding ') (we'll parse the contents later)
contents = '[^)]*';
% Closing bracket
suffix = '(?=\))';

[ibeg, iend] = regexp(txt, [prefix, contents, suffix]);
if isempty(ibeg)
    % No entry found for the the value of var
    out = {};
    return
elseif numel(ibeg)>1 || ibeg==iend
    error('HORACE:validate', ['A single definition of a variable of form:\n', ...
        '    set(%s A B C ...)\n', 'was not found'], var)
end
str = txt(ibeg:iend);

% Now check that str is entirely made of strings of the form "ccc..." (where c is
% any character) separated by at least one whitespace character
% (Add a trailing whitespace character for the regexp search to catch the final token)
ibeg = regexp([str, ' '], '("(.*)"\s+)*');
if ~isscalar(ibeg)
    error('HORACE:validate', ['Line(s) defining a variable of form:\n', ...
        '    set(%s A B C ...)\n', ...
        'with A, B, C of form "ccc...c" (c=any character) not found'], var)
end

% Confirmed that we have the correct form, so get the contents between pairs of
% quotes
ix = regexp(str, '"');
out = arrayfun(@(x,y)(str(x:y)), ix(1:2:end-1)+1, ix(2:2:end)-1, 'UniformOutput', false);
if any(cellfun(@isempty, out))
    error('HORACE:validate', ['Empty variable found in:\n', ...
        '    set(%s A B C ...)'], var)
end
