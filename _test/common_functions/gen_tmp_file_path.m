function tmp_file_path = gen_tmp_file_path(suffix)
% Get a temporary file path, the file's name will contain the name of the
% calling function and the process ID.
%
% Including the name of the calling function allows us to easily see where the
% file has come from. Including the pid ensures concurrent processes do not
% produce the same file.
%
if nargin == 0
    suffix = '';
end
call_stack = dbstack();
caller_name = call_stack(2).name;
process_id = num2str(feature('getpid'));
file_name = [caller_name, '_', process_id, suffix, '.tmp'];
tmp_file_path = fullfile(tmp_dir(), file_name);

end
