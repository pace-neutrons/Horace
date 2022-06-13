function [hpc_cli,hpc_opt] = hpc(varargin)
% function tries to identify if current system is a high performance
% computer and sets up hpc options which assumed to be optimal for current system
%
% based on very limited experience of comparing different systems in ISIS
% recorded on Horace Download and setup web page:
% (http://horace.isis.rl.ac.uk/Download_and_setup)
%
% User should try to identify optimal hpc setting for his particular computer
% and not rely very much on the results, produced by this command, though
% it should be ok to run in on isiscompute.
%
% Usage:
%>>hpc on    -- enable hpc computing extensions
%>>hpc off   -- disable hpc computing extensions
%>>hpc       -- print current hpc computing extensions value and the values,
%               recommended by this function (very crude estimate)
%
% If provided with output arguments, two structures, defining configurations:
% namely
% [hpc_cli,hpc_opt] = hpc(___);
% where
% hpc_cli  -- the current hpc configuration, used by computer
%                  (changes if hpc is on)
% hpc_opt  -- the configuration, assumed to be optimal for the
%             identified type of the machine.
%
%
% The meaning of hpc properties is described by hpc_config configuration
%                        file.
%  combine_sqw_using: matlab/mex_code/mpi_code -- should mex extension be
%                                      combine tmp files, if such extension
%                                      is available, or if mpi code to be
%                                      used for combining (currently test
%                                      option) or matlab code (slow serial
%                                      option used for backup)
%  mex_combine_thread_mode:      0  use mex file for combining and run
%                                   separate input and output thread
%                                1  use mex file for combining and in
%                                   addition to option 0, spawn separate
%                                   input thread for each input file
%                                2  debugging option related to option 1
%                                3  debugging option related to option 1
%  mex_combine_buffer_size: 65536 -- file buffer used for each input file in mex-file combining
%
%  build_sqw_in_parallel:   0  -- use separate Matlab sessions when processing input spe or nxspe files
%  parallel_workers_number: 4  -- number of parallel sessions to use.
%
%  The options, presumed to be optimal are identified according to the
%  computer type and managed by opt_config_manager class.

hpc_cli = hpc_config();
hpc_options_names = hpc_cli.hpc_options;

if nargin>0
    val = varargin{1};

    switch val
      case 'on'
        hpc_cli.build_sqw_in_parallel = true;
      case 'off'
        ocp = opt_config_manager();
        % load configuration, assumed optimal for calculated type of the computer.
        ocp = ocp.load_configuration();
        config = ocp.optimal_config;
        hpc_opt = config.hpc_config;

        flds = fieldnames(hpc_opt);
        for i=1:numel(flds)
            hpc_cli.(flds{i}) = hpc_opt.(flds{i});
        end
        hpc_cli.build_sqw_in_parallel = false;
      otherwise
        fprintf('Unknown hpc option ''%s'', Use ''on'' or ''off'' only\n',varargin{1});
    end
else

    ocp = opt_config_manager();
    % load configuration, assumed optimal for calculated type of the computer.
    ocp = ocp.load_configuration(varargin{:});
    config = ocp.optimal_config;
    hpc_opt = config.hpc_config;

    disp('|-------------------------|----------------|----------------|');
    disp('| computer hpc options    | current val    | recommended val|');
    disp('|-------------------------|----------------|----------------|');
    format_ticks = [2];
    for i=1:numel(hpc_options_names)
        opt = hpc_options_names{i};
        exist_val = hpc_cli.(opt);
        opt_val   = hpc_opt.(opt);
        if isnumeric(exist_val) || islogical(exist_val)
            fprintf('| %23s | %14d | %14d |\n',opt,exist_val,opt_val);
        elseif ischar(exist_val)
            fprintf('| %23s | %14s | %14s |\n',opt,exist_val,opt_val);
        end
        is_tick = intersect(format_ticks,i);
        if ~isempty(is_tick)
            disp('|-------------------------|----------------|----------------|');
        end
    end
    disp('-------------------------------------------------------------');
end
