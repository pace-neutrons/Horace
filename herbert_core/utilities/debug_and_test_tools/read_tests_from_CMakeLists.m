function [horace_tests, herbert_tests, system_tests] = read_tests_from_CMakeLists
% Read CMakeLists.txt on the Horace tests path and extract all tests

test_path = horace_paths().test;
filename = fullfile(test_path, 'CMakeLists.txt');
% filename = 'T:\matlab\Work\PACE\1871-validate_horace\crap.txt';

txt = read_text_file_as_string (filename);
herbert_tests = get_tests_from_string (txt, 'HERBERT_TESTS');
herbert_system_tests = get_tests_from_string (txt, 'HERBERT_TESTS');
horace_tests = get_tests_from_string (txt, 'HORACE_TESTS');
horace_system_tests = get_tests_from_string (txt, 'HORACE_TESTS');

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
