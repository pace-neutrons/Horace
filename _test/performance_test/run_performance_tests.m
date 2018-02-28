function perf_res = run_performance_tests(varargin)
% function to run performance test on a given pc or cluster
%
% Usage:
% perf_results = run_performance_tests([n_workers])
%
% optional variable n_workers tries to run performance tests with number of
% workers, specified as input.
% returns:
% perf_results  -- the structure containing the performance results for
%                  given pc
% these results are also stored in special file, defined by
% test_SQW_GENCUT_perf  class overwriting previous values for the same
% machine if such values were present
%

perf_res = struct('small_ds_perf',[],'medium_ds_perf',[],'large_ds_perf',[]);


hor_tes = test_SQW_GENCUT_perf();
% if hpc extensions are availible and enabled try to run the test in parallel
hc = hpc_config;
if nargin == 0
    if hc.accum_in_separate_process
        n_workers = hc.accumulating_process_num;
    else
        n_workers = 0;
    end
else
    n_workers = varargin{1};
end

%--------------------------------------------------------------------------
% run performance tests for small sqw file (default file)
small_perf = hor_tes.test_gensqw_performance(n_workers);
perf_res.small_ds_perf = small_perf;
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
medium_perf = hor_tes.test_gensqw_performance(n_workers);
perf_res.medium_ds_perf = medium_perf;
%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
%run performance for combining tmp files only (depends on presious test
%complteted successfully and left tmp files to combine)
medium_perf = hor_tes.combine_performance_test(n_workers);
perf_res.medium_ds_perf = medium_perf;
%--------------------------------------------------------------------------
clear clob_tmp; % reset configuration not to keep tmp files any more

%
% prepare performance tests for large dataset
hor_tes.n_files_to_use = 250;
large_perf = hor_tes.test_gensqw_performance(n_workers);
perf_res.large_ds_perf = large_perf;


