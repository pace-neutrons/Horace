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

%hor_tes = test_SQW_GENCUT_perf(); % build new performance results per
%                                  session
hor_tes = test_SQW_GENCUT_perf(... % Load previous performance result, do not recalculate
    fullfile(fileparts(mfilename('fullpath')),'test_SQW_GENCUT_perf_PerfRez.xml'));
%
hpcc = hpc_config;
conf_2store = hpcc.get_data_to_store;
clob = onCleanup(@()set(hpcc,conf_2store));
hpcc.saveable = false;
hpcc.build_sqw_in_parallel = 0;

hrc = hor_config;
hrc.saveable = false;
hrc.delete_tmp = false;
clob1 = onCleanup(@()set(hrc,'delete_tmp',true));


hor_tes.n_files_to_use=50;

%n_workers = [0,1,2,4,6,8,10,12,14,16,20,32];
n_workers = [0,1,2,4,8,12,14,16]; % local machine
perf_graph = zeros(numel(n_workers),3);

for i=1:numel(n_workers)
    nwk = num2str(n_workers(i));
    hor_tes.build_default_test_names(nwk);
    test_names_map = hor_tes.default_test_names;
    tn = test_names_map('gen_sqw');
    per1 = hor_tes.known_performance(tn{1});
    per2 = hor_tes.known_performance(tn{2});
    if isempty(per1) || isempty(per2) || force_perf
        try
            perf_rez = hor_tes.test_gensqw_performance(n_workers(i),'gen_sqw');
        catch ME
            perf_graph = perf_graph(1:i-1,:);
            plot(perf_graph(:,1),perf_graph(:,2),'o-');
            getReport(ME)
            rethrow(ME);
        end
        per1 = perf_rez.(tn{1});
        per2 = perf_rez.(tn{2});
    end
    
    perf_graph(i,1) = n_workers(i);
    perf_graph(i,2) = per1.time_sec/hor_tes.data_size;
    perf_graph(i,3) = per2.time_sec/hor_tes.data_size;
    
end
% Process some averages to display
min_gen_time = min(perf_graph(:,2));
max_gen_time = max(perf_graph(:,2));
min_comb_time = min(perf_graph(:,3));
max_comb_time = max(perf_graph(:,3));

min_prod_time = round((min_gen_time+min_comb_time)*hor_tes.data_size/60,1); % in minutes
max_prod_time = round((max_gen_time+max_comb_time)*hor_tes.data_size/60,1); % in minutes
tc1 = strrep(tn{1},'_','\_');
tc2 = strrep(tn{2},'_','\_');
title_string = sprintf(['Dataset silze~ %dGb, %d input files;\n',...
    ' Final DB test codes:\n %s; %s\n',...
    'Production time: min=%.1f(min); max=%.1f(min)'],...
    round(hor_tes.data_size),hor_tes.n_files_to_use,...
    tc1,tc2,min_prod_time,max_prod_time );

%plot results
figure;
plot(perf_graph(:,1),perf_graph(:,2),'o-');
ylabel('Processing Time (sec/Gb)')
xlabel('n-workers');
title(title_string)
hold on
plot(perf_graph(:,1),perf_graph(:,3),'*-');
legend('gen\_tmp perf','combine perf')

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
        addinfo = sprintf('_buf%d',64*1024);
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
            plot(comb_perf(:,1),comb_perf(:,2),'o-');
            return
        end
        
        per = perf_rez.(test_name);
    end
    comb_perf(i,1) = buf;
    comb_perf(i,2) = per.time_sec;
    
end
figure
plot(comb_perf(:,1),comb_perf(:,2),'o-');


