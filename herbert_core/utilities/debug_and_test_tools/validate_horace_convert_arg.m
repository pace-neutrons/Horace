function name_out = validate_horace_convert_arg(test_dir, name)
% Utility routine to convert a validate_horace test suite location argument into
% one for the xunit tests function runtests.
%
% Input:
% ------
%   test_dir    Root directory for the tests suite in Horace. Has the form:
%                   <horace_root_dir>/_test.
%   name        Argument giving tests name. Has one of the general forms:
%                   mfile
%                   mfile:testname
%                   folder
%                   folder/mfile
%                   folder/mfile:testname
%               See validate_horace for more details.
%
% Outut:
% ------
%   name_out    Converted value of name accounring for the relative path of a
%               folder.

if exist(fullfile(test_dir, name), 'dir')
    % name is a folder relative to root_dir; return absolute path
    name_out = fullfile(test_dir, name);
else
    % name is not a relative folder so, if it is valid at all, it must be an
    % mfile name, with or without a folder too, and with or without a test
    % instance i.e.
    %   mfile,  mfile:testname,  folder/mfile  or  folder/mfile:testname
    % Parse to find out which, and if a folder name is found, get the absolute
    % path.
    folder = split_folder_from_tests (name);
    if ~isempty(folder)
        name_out = fullfile(test_dir, name);
    else
        name_out = name;
    end
end
end   

%-------------------------------------------------------------------------------
function [folder, file, name] = split_folder_from_tests (arg)
% Attempt to split into a folder and mfilename with the form
%   folder/mfile
%   folder/mfile:testname
%
% Returns
%   folder      The name of the folder
%   file        The name of the mfile
%   name        The name of the test. This could be one of
%               - mfile
%               - mfile:testname


% Find occurences of ':'. These could be because the input has a full path on a
% Windows computer, and/or a single test name within a test suite (which is
% demarcated by ':' or '::')
ddot_ind = strfind(arg,':');

% Skip over disk in full path if PC
if ispc && ~isempty(ddot_ind) && numel(arg)>=3 && any(strcmp(arg(2:3),{':\', ':/'}))
    % Begins '*:\' or '*:/' as would be expected if arg has a full Windows path
    ddot_ind = ddot_ind(2:end);     % indices of any remaining ':'
end

% Get test folder and test file name
if ~isempty(ddot_ind)
    % This demarcates a particular test case within the mfile
    full_file = arg(1:ddot_ind(1)-1);
    test_case = arg(ddot_ind(1):end);
else
    full_file = arg;
    test_case = '';
end

[folder, file] = fileparts(full_file);
name = [file, test_case];   % re-append particular test, if present

end
