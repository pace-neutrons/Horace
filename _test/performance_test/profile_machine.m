function [perf_graph,comb_perf]=profile_machine(force_perf_recalculation)
% measures a machine performance as function of number of parallel workers
% or returns the performance stored for this machine earlier.
% if force_perf_recalculation is present, the previous perofmance results
% are ignored and the performance is measured afresh.
%
if nargin>0
    force_perf = true;
else
    force_perf = false;
end

hor_tes = test_SQW_GENCUT_perf();
hpcc = hpc_config;
conf_2store = hpcc.get_data_to_store;
clob = onCleanup(@()set(hpcc,conf_2store));
hpcc.saveable = false;
hpcc.build_sqw_in_parallel = 0;

hrc = hor_config;
hrc.saveable = false;
hrc.delete_tmp = false;
clob1 = onCleanup(@()set(hrc,'delete_tmp',true));

% get the method used to combine partial sqw files together. Used in
% calculating test performance name
comb_method = hor_tes.combine_method();

hor_tes.n_files_to_use=5;

n_workers = [0,1,2,4,6,8,10,12,14,16];
perf_graph = zeros(numel(n_workers),2);

for i=1:numel(n_workers)
    nwk = num2str(n_workers(i));
    test_name = sprintf('gen_sqw_nwk%s_comb_%s',nwk,comb_method);
    per = hor_tes.knownPerformance(test_name);
    if isempty(per) || force_perf
        try
            perf_rez = hor_tes.test_gensqw_performance(n_workers(i),'gen_sqw');
        catch
            perf_graph = perf_graph(1:i-1,:);
            plot(perf_graph(:,1),perf_graph(:,2));
            return
        end
        per = perf_rez.(test_name);
    end
    
    perf_graph(i,1) = n_workers(i);
    perf_graph(i,2) = per.time_sec;
    
end
plot(perf_graph(:,1),perf_graph(:,2));

buf_val = [-1,0,1024,2048,4*1024,8*1024,16*1024,32*1024,64*1024];
comb_perf = zeros(numel(buf_val),2);
hpcc.mex_combine_thread_mode = 0;
keep_tmp = '-keep';
n_buf = numel(buf_val);
for i=1:n_buf
    buf = buf_val(i);
    if buf <0
        hpcc.mex_combine_thread_mode = 0;
        hpcc.combine_sqw_using = 'matlab';
        addinfo = '';
    elseif buf == 0
        hpcc.mex_combine_thread_mode = 0;
        hpcc.combine_sqw_using = 'mex_code';
        hpcc.mex_combine_buffer_size = 64*1024;
        addinfo = sprintf('_buf%d',buf);
    else
        hpcc.mex_combine_thread_mode = 1;
        hpcc.mex_combine_buffer_size = buf;
        addinfo = sprintf('_buf%d',buf);
    end
    if i== n_buf
        keep_tmp = '';
    end
    
    combine_method = hor_tes.combine_method(addinfo);
    test_name = ['combine_tmp_using_',combine_method];
    per = hor_tes.knownPerformance(test_name);
    if isempty(per) || force_perf
        try
            perf_rez = hor_tes.combine_performance_test(0,addinfo,keep_tmp);
        catch
            comb_perf = comb_perf(1:i-1,:);
            plot(comb_perf(:,1),comb_perf(:,2));
            return
        end
        
        per = perf_rez.(test_name);
    end
    comb_perf(i,1) = buf;
    comb_perf(i,2) = per.time_sec;
        
end
figure
plot(comb_perf(:,1),comb_perf(:,2),'o');


