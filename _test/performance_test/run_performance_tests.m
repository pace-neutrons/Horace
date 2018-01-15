function perf_res = run_performance_tests()
% function to run performance test on a given pc or cluster

perf_res = struct('small_ds_perf',[],'medium_ds_perf',[],'large_ds_perf',[]);


hor_tes = test_SQW_GENCUT_perf();
% if hpc extensions are availible and enabled try to run the test in parallel
hc = hor_config;
if hc.accum_in_separate_process
    n_workers = hc.accumulating_process_num;
else
    n_workers = 0;
end


% run performance tests for small (default file)
small_perf = hor_tes.test_gensqw_performance(n_workers);
perf_res.small_ds_perf = small_perf;

% prepare performance tests for medium dataset
hor_tes.n_files_to_use = 50;
medium_perf = hor_tes.test_gensqw_performance(n_workers);
perf_res.medium_ds_perf = medium_perf;

%
% prepare performance tests for large dataset
hor_tes.n_files_to_use = 250;
large_perf = hor_tes.test_gensqw_performance(n_workers);
perf_res.large_ds_perf = large_perf;







