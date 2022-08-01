function benchmark_horace(varargin)
%BENCHMARK_HORACE Summary of this function goes here
%   Runs benchmarking of Horace installation
%
%   >> benchmark_horace         % Run full Horace benchmarks
%   >> benchmark_horace (foldername)       %  Run Horace benchmaking on the single named folder
%   >> benchmark_horace (foldername1, foldername2)  %  Run Horace benchmarking on named folders
%   >> benchmark_horace (foldname_cell)  %  Run Horace benchmarking on the folders named
%                                        % in a cell array of names
% In addition, one of more options are allowed fromt he following
%
%   >> benchmark_horace (...'-parallel') %  Enables parallel execution of benchmark tests
%                                        % if the parallel computer toolbox is available
%                                        % If -paralleel is not specified,
%                                        % benchmarks will be run in serial
%   >> benchmark_horace (...'-verbose')%  Prints output of the benchmarks and
%                                        % horace commands (log_level is set to default,
%                                        % not quiet)
%   >> benchmark_horace (...'-nomex')    %  Validate matlab code by forcefully
%                                        % disabling mex even if mex files
%                                        % are available
%   >> benchmark_horace (...'-forcemex') %  Enforce use of mex files only. The
%                                        % default otherwise for Horace to revert to
%                                        % using matlab code.
%   >> benchmark_horace (...'-exit_on_completion') % Exit Matlab when test suite ends.
%   >> benchmark_horace (...'-smallData')%  Runs benchmarks using the
%                                        % "small" data set
%   >> benchmark_horace (...'-mediumData') %  Runs benchmarks using the
%                                          % "medium" data set
%   >> benchmark_horace (...'-largeData')%  Runs benchmarks using the
%                                        % "large" data set
%   >> benchmark_horace ('bm_cut_sqw','-smallData')% Runs cut_sqw
%                                                  % benchmarks using the"small" data set

options = {'-verbose',  '-nomex',  '-forcemex',  '-exit_on_completion',...
    '-smallData', '-mediumData', '-largeData'};
[ok, mess, verbose, nomex, forcemex, exit_on_completion, smallData, mediumData,...
    largeData, bm_folders] = parse_char_options(varargin, options);

if ~ok
     error('HORACE:benchmark_horace:invalid_argument', mess)
end

% try
%     [~, verbose, nomex, forcemex, exit_on_completion, smallData, mediumData,...
%         largeData, bm_folders] = parse_char_options(varargin, options);
% catch ME
%     switch ME.identifier
%         case 'PACE:errorClass'
%           warning("Error identified and caught")
%         case {'PACE:errorClass1', 'PACE:errorClass2'}
%          warning("Error is class1 or 2")
%         otherwise
%          rethrow(ME)
%    end
% end

%==============================================================================
% Place list of benchmarking folders here (relative to the master _benchmarking folder)

if isempty(bm_folders)% no tests specified on command line - run them all
    bm_folders = {...
        'bm_cut_sqw', ...
        'bm_combine_sqw'...
        'bm_func_eval'...
        'bm_sqw_eval'...
        'bm_tobyfit'...
%         'bm_gen_sqw'...
%         'bm_multifit_simulate'...
%         'bm_multifit_fit'...
        };
end

% Generate full path to benchmarking tests
% --------------------------------------
pths = horace_paths;
bm_path = pths.bm;
bm_folders_full = fullfile(bm_path, bm_folders);

% Get and store intial Horace config
% --------------------------------------
hoc = hor_config();
cur_horace_config = hoc.get_data_to_store();
clear config_store;

% Create cleanup object (to revert to intial Horace config on exit)
% --------------------------------------
cleanup_obj = onCleanup(@() ...
    benchmark_horace_cleanup(cur_horace_config));

% Special settings for certain benchmarks
hoc.use_mex = ~nomex;
hoc.force_mex_if_use_mex = forcemex;

if verbose
    hoc.log_level = 1; % force log level high.
else
    hoc.log_level = -1; % turn off informational output
end

% %% Genrate the sqw objects needed for the benhcmarks
% bigtic
% % gen_fake_sqw_data(5);
% gen_fake_sqw_data(6);
% gen_fake_sqw_data(7);
% gen_fake_sqw_data(8);
% % gen_fake_sqw_data(9);
% bigtoc

%% Run benchmarks for small sized data set
if smallData
    for i = 1:numel(bm_folders_full)
        % Get filenames for benchmarks in each folder
        current_folder = dir(bm_folders_full{i});
        available_benchmarks = current_folder(~([current_folder.isdir]));
        % Get filenames for all smallData_serial benchmarks
        for j=1:numel(available_benchmarks)
            benchmark = strfind(available_benchmarks(j).name, 'smallData.m');
            if ~isempty(benchmark)
                bm_filepath = fullfile(bm_folders_full{i}, available_benchmarks(j).name);
                runtests(bm_filepath)
            end
        end
    end
%% Run benchmarks for a medium sized data set
elseif mediumData
    for i = 1:numel(bm_folders_full)
        % Get filenames for benchmarks in each folder
        current_folder = dir(bm_folders_full{i});
        available_benchmarks = current_folder(~([current_folder.isdir]));
        % Get filenames for all mediumData_serial benchmarks
        for j=1:numel(available_benchmarks)
            benchmark = strfind(available_benchmarks(j).name, 'mediumData.m');
            if ~isempty(benchmark)
                bm_filepath = fullfile(bm_folders_full{i}, available_benchmarks(j).name);
                runtests(bm_filepath)
            end
        end
    end
%% Run benchmarks for large sized data set
elseif largeData
    for i = 1:numel(bm_folders_full)
        % Get filenames for benchmarks in each folder
        current_folder = dir(bm_folders_full{i});
        available_benchmarks = current_folder(~([current_folder.isdir]));
        % Get filenames for all largeData_serial benchmarks
        for j=1:numel(available_benchmarks)
            benchmark = strfind(available_benchmarks(j).name, 'largeData.m');
            if ~isempty(benchmark)
                bm_filepath = fullfile(bm_folders_full{i}, available_benchmarks(j).name);
                runtests(bm_filepath)
            end
        end
    end
%% Run all benchmarks (small, medium and large data sets)
else
    for i = 1:numel(bm_folders_full)
        runtests(bm_folders_full{i})
    end
end

if exit_on_completion
    exit(err);
end

end

function benchmark_horace_cleanup(cur_horace_config)
% Reset the configurations for Horace and HPC
set(hor_config, cur_horace_config);
% DELETE GENERATED SQW FILES
% delete(string(smallDataSource))
end