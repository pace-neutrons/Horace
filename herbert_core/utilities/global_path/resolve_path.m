function fullpath = resolve_path(filename)
% Function to resolve full path to a file or a folder
%
%
if ~ischar(filename)
    error('RESOLVE_PATH:invalid_argument',...
        'input should be a string, identifying file or path to a file. Got: %s',...
        fevalc('disp(filename)'))
end

file=java.io.File(filename);
fullpath = char(file.getCanonicalPath());
if fullpath(end) == '~'
    fullpath = fullpath(1:end-1);
end

if file.exists()
    return
else
    error('RESOLVE_PATH:runtime_error',...
        'Does not exist or failed to resolve absolute path for "%s"',...
        filename);
end