function validate_horace_cleanup(initial_dir, cur_horace_config, cur_hpc_config, ...
    cur_par_config, initial_warn_state, test_folders, log_filename, log_filename_tmp)
% Reset Horace and warning configurations and concatenate temporary logfiles
% from each of the calls to runtests, if there are any logfiles

% Return to initial working directory
cd(initial_dir)

% Reset the configurations
set(hor_config, cur_horace_config);
set(hpc_config, cur_hpc_config);
set(parallel_config, cur_par_config);

% Restore warnings to initial state
warning(initial_warn_state);

% Remove unit test folders previously placed on the path
state = warning('off', 'MATLAB:rmpath:DirNotFound'); % avoid warning on deleting non-existent path
for i = 1:numel(test_folders)
    rmpath(test_folders{i});
end
warning(state)  % return warning to initial state

% Create log file if there are temporary log files to be concatenated, and then
% delete the temporary log files
% Perform this operation in this cleanup function in case validate_horace
% crashes; at least all logfiles up to this point will then be concatenated.
state = warning('off', 'MATLAB:DELETE:FileNotFound');
if ~isempty(log_filename_tmp)
    % There are logfiles to be concatenated into a single file
    concatente_text_files(log_filename_tmp{:}, log_filename)
    try     % you never know if you can be certain of deleting a file... don't crash in the cleanup!
        delete(log_filename_tmp{:})
    catch
    end
end
warning(state)  % return warning to initial state

end


%-------------------------------------------------------------------------------
function concatente_text_files (varargin)
% Concatenate a set of text files
%
%   >> concatente_text_files (filename1, filename2, ... filename_out)

if nargin < 2
    return  % no files or just one file - do nothing
end

fid = fopen(varargin{end}, 'w');
nfiles = nargin - 1;
for i = 1:nfiles
    A = fileread(varargin{i});
    if i < nfiles
        fprintf(fid, '%s\n', A);
    else
        fprintf(fid, '%s', A);
    end
end
fclose(fid);
end
