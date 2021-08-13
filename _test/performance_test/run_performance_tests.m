function [perf_res,hor_tes] = run_performance_tests(varargin)
% function to run performance test on a given pc or cluster
%
% Usage:
% perf_results = run_performance_tests([n_workers],[the_test])
%
% optional variables:
% n_workers --  tries to run performance tests with number of
%               workers, specified as input.
% the_test  -- run only the test(s) specified as input. More then one test
%              name should be specified in a cellarray of names
%
% returns:
% perf_results  -- the structure containing the performance results for
%                  given pc
%
% these results are also stored in special file, defined by
% test_SQW_GENCUT_perf  class overwriting previous values for the same
% machine if such values were present
%

perf_res = struct('small_ds_perf',[],'medium_ds_perf',[],'large_ds_perf',[]);


hor_tes = test_SQW_GENCUT_perf();
% if hpc extensions are available and enabled try to run the test in parallel
hc = hpc_config;
if nargin == 0
    if hc.build_sqw_in_parallel
        n_workers = hc.parallel_workers_number;
    else
        n_workers = 0;
    end
else
    n_workers = varargin{1};
end
if nargin == 2
    selected_tests = varargin{2};
else
    selected_tests = [];    
end

%--------------------------------------------------------------------------
% run performance tests for small sqw file (default file)
hor_tes.n_files_to_use = 10;

small_perf = hor_tes.workflow_performance(n_workers,selected_tests);
perf_res.small_ds_perf = small_perf;
hor_tes.save_performance();
%--------------------------------------------------------------------------

% prepare performance tests for medium dataset
hor_tes.n_files_to_use = 50;
% run the test in the mode, holding tmp files
% to test file combine operations separately.
hc = hor_config;
% get the data one needs to restore
hcd = hc.get_data_to_store;
clob_tmp = onCleanup(@()set(hc,hcd));
hc.delete_tmp = 0;
%--------------------------------------------------------------------------
% run performance tests for medium size file
medium_perf = hor_tes.workflow_performance(n_workers,selected_tests);
perf_res.medium_ds_perf = medium_perf;
hor_tes.save_performance();
%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
%run performance for combining tmp files only (depends on previous test
%completed successfully and left tmp files to combine during this test)
medium_perf = hor_tes.combine_task_performance(n_workers);
perf_res.medium_ds_perf = medium_perf;
%--------------------------------------------------------------------------
clear clob_tmp; % reset configuration not to keep tmp files any more

%
% prepare performance tests for large dataset
hor_tes.n_files_to_use = 250;
large_perf = hor_tes.workflow_performance(n_workers,selected_tests);
perf_res.large_ds_perf = large_perf;
%
hor_tes.save_performance();
hor_tes.save_to_csv();


