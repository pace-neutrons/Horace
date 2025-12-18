function validate_horace_cleanup(initial_horace_config, initial_hpc_config, ...
    initial_par_config, test_args, initial_warn_state, varargin)
% Reset Horace and warning configurations and concatenate temporary logfiles
% from each of the calls to runtests, if there are any logfiles.
%
% Input:
% ------
%   initial_horace_config   Configuration state to return hor_config to.
%   initial_hpc_config      Configuration state to return hpc_config to.
%   initial_parallel_config Configuration state to return parallel_config to.
%   test_args               Cell array of the full paths to test folders,
%                           testCase subclasses or particular test methods in
%                           testCase subclasses.
%   initial_warn_state      Warnings state to which to return.
% 
% Optional arguments:
%   initial_dir             Full path to which to return to as the pwd.
%                           Set to [] to ignore.
%   log_filename            Name of output log file in which to concatentate
%                          the contents of the temporary log files in the
%                          log_filename_tmp, below.
%                           Set to '' to skip concatenation.
%   log_filename_tmp        Cell array of temporary log file names. The files 
%                          will be deleted on exit.
%                           If {} then no concatenation will take place.


% Defaults for optional input arguments
initial_dir = [];
log_filename = '';
log_filename_tmp = {};

% Parse input
narg = numel(varargin);
if narg>=1
    initial_dir = varargin{1};
end
if narg>=2
    log_filename = varargin{2};
end
if narg>=1
    log_filename_tmp = varargin{3};
end


% Return to initial working directory
if ~isempty(initial_dir)
    cd(initial_dir)
end

% Reset the configurations
set(hor_config, initial_horace_config);
set(hpc_config, initial_hpc_config);
set(parallel_config, initial_par_config);

% Restore warnings to initial state
warning(initial_warn_state);

% Remove unit test folders previously placed on the path
state = warning('off', 'MATLAB:rmpath:DirNotFound'); % avoid warning on deleting non-existent path
for i = 1:numel(test_args)
    rmpath(test_args{i});
end
warning(state)  % return warning to initial state

% Create log file if there are temporary log files to be concatenated, and then
% delete the temporary log files.
% Perform this operation in this cleanup function in case validate_horace
% crashes; at least all logfiles up to this point will then be concatenated.
state = warning('off', 'MATLAB:DELETE:FileNotFound');
if ~isempty(log_filename) && ~isempty(log_filename_tmp)
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
