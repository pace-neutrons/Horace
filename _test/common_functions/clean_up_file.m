function clean_up_file(file_path)
%%CLEAN_UP_FILE Delete the given file
% This function will check if the file is currently open in Matlab and close it
% if so.
%
if ~exist(file_path, 'file')
    % If the file doesn't exist, nothing to do
    return;
end

% Get list of all open file IDs and the names of the files
all_open_fids = fopen('all');
open_file_names = arrayfun(@fopen, all_open_fids, 'UniformOutput', 0);

% Get the file IDs that correspond to open instances of 'file_path'
fid_logical_idxs = cellfun(@(x) strcmpi(file_path, x), open_file_names);
file_fids = all_open_fids(fid_logical_idxs);

% Close all open instances of 'file_path'
for i = 1:numel(file_fids)
    fclose(file_fids(i));
end

delete(file_path);
