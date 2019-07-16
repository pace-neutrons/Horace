function perf_graph=profile_machine

hor_tes = test_SQW_GENCUT_perf();
hc = hpc_config;
conf_2store = hc.get_data_to_store;
clob = onCleanup(@()set(hc,conf_2store));
hc.build_sqw_in_parallel = 0;

hor_tes.n_files_to_use=50;

n_workers = [0,1,2,4,6,8,10,12,14,16];
perf_graph = zeros(numel(n_workers),2);
fields = {};
for i=1:numel(n_workers)
    try
        perf_rez = hor_tes.test_gensqw_performance(n_workers(i),'gen_sqw');
    catch
        perf_graph = perf_graph(1:i-1,:);
        plot(perf_graph(:,1),perf_graph(:,2));        
        return
    end
    fn = fieldnames(perf_rez);
    new = ~ismember(fn,fields);
    perf_graph(i,1) = n_workers(i);
    new_res = find(new,1);
    if isempty(new_res)
        new_res = numel(fn);
    end
    per = perf_rez.(fn{new_res});
    perf_graph(i,2) = per.time_sec;
    fields = fn;
end
plot(perf_graph(:,1),perf_graph(:,2));