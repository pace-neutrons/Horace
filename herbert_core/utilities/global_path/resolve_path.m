function fullpath = resolve_path(filename)
% Function to resolve full path to a file or a folder
%
%
if ~ischar(filename)
    error('RESOLVE_PATH:invalid_argument',...
        'input should be a string, identifying file or path to a file. Got: %s',...
        fevalc('disp(filename)'))
end

if isunix
    if filename(1) == '~'  % homedir
        file = java.io.File(getuserdir(), filename(2:end));
    else
        file = java.io.File(pwd(), filename);
    end
else
  file = java.io.File(filename);
end
fullpath = char(file.getCanonicalPath());

if exist(fullpath,'file') > 0
    return
else
    error('RESOLVE_PATH:runtime_error',...
        'Does not exist or failed to resolve absolute path for "%s"',...
        filename);
end