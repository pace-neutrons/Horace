function file_name = build_tmp_file_name(base_name,filepath)
% Function build temporary file name on the basis of the original name
% adding to the file name the temporary extension .tmp_random_string
%
% Input:
% base_name  -- the name of the file to add random extension consisting of
%               12 random characters.
%
% Optional:
% filepath   -- if present, build temporary filepath in the folder,
%               specified in this variable
%
% Returns:
% file_name  -- the temporary filename in the form:
%               filepath/base_name.tmp_xxxx
%               where xxxx represents 12 random characters.
%
[~, name] = fileparts(base_name);
if nargin == 1
    filepath = tmp_dir();
end

for i = 1:5
    file_name = fullfile(filepath, ...
        [name, '.tmp_', str_random()]);
    if ~is_file(file_name)
        break
    end
end
% Unlikely to happen, but best to check fail to generate
if i == 5 && is_file(file_name)
    error('HERBERT:utilities:runtime_error', ...
        ['Can not generate available tmp file name for: %s in folder: %s\n', ...
        'Check target folder and clear any .tmp_<id> files'], ...
        base_name,filepath);
end
