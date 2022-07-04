function handle = get_shadowed_function_handle(fn_name, original_mfile)
% Gets the handle to a shadowed function by changing to its folder
%
% Usage:
%
% handle = get_shadowed_function_handle(function_name, original_mfile)
%
% Input:
%
% function_name - the function name as a string
% original_mfile - (optional) the full path to the calling mfile
%
% Output:
%
% handle - the handle to the shadowed function.
%          If `original_mfile` is specified, this is the next function
%          in the list returned by `which(function_name, '-all')` after
%          the function specified by `original_mfile`.
%          If `original_mfile` is *not* specified, this is the built-in
%          Matlab function (with a path under `matlabroot`).
%
% This function will only get the handle of functions described in their
% own mfiles - e.g. not class methods, and not nested functions.

err_code = 'HERBERT:get_shadowed_function_handle:runtime_error';
list = which(fn_name, '-all');
if nargin > 1
    % locate function in list after original_mfile
    outer_dir = fileparts(original_mfile);
    curfil = strcmp(list, [outer_dir filesep fn_name '.m']);
    assert(~isempty(curfil), err_code, 'Original mfile not found in `which -all` list');
    is_fun = cellfun(@(x) contains(x, [fn_name '.m']), list);
    notmeth = ~cellfun(@(x) contains(x, '@'), list);
    f = xor(curfil, is_fun) & notmeth;
else
    % locate 1st in list under matlabroot
    f = strncmp(list, matlabroot, numel(matlabroot));
end
assert(any(f), err_code, 'Cannot find "%s" function!', fn_name);
[funcpath, ~] = fileparts(list{find(f, 1, 'first')});
here = cd(funcpath);              % temporarily switch to the containing folder
cleanup = onCleanup(@()cd(here)); % go back to where we came from after regardless
handle = str2func(fn_name);       % grab a handle to the function
clear('cleanup');                 % explicitly return

