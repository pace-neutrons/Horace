function [fullpath,ok] = resolve_path(filename)
% Function to resolve full path to a file or a folder
%
% Returns:
% Full path to the file
% ok -- if file exist and can be resolved, ok==true
%       if false, file not exist
%
if ~ischar(filename)
    error('RESOLVE_PATH:invalid_argument',...
        'input should be a string, identifying file or path to a file. Got: %s',...
        evalc('disp(filename)'))
end

if isunix
    if filename(1) == '~'  % homedir
        file = java.io.File(fullfile(getuserdir(), filename(2:end)));
    else
        if exist(fullfile(pwd(),filename),'file')
            fullpath = fullfile(pwd(),filename);
            file = java.io.File(fullpath);
        else
            file = java.io.File(filename);
        end
    end
else
    if exist(fullfile(pwd(),filename),'file')
        fullpath = fullfile(pwd(),filename);
        file = java.io.File(fullpath);
    else
        file = java.io.File(filename);
    end
end
fullpath = char(file.getCanonicalPath());

if exist(fullpath, 'file') % Don't care if file or folder
    ok = true;
    return
else
    if nargout<2
        error('RESOLVE_PATH:runtime_error',...
            'Does not exist or failed to resolve absolute path for "%s"',...
            filename);
    else
        ok = false;
    end
end