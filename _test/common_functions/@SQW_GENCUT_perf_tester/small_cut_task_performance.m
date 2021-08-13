function [perf_res,sqw1,sqw2,sqw3,sqw4] = small_cut_task_performance(obj,field_names_map)
% check the perfromance of a small cut operation
test_fld_names = field_names_map('small_cut');
% test small 1 dimensional cuts, non-axis aligned
ts = tic();
proj1 = struct('u',[1,0,0],'v',[0,1,1]);
sqw1 = cut_sqw(obj.sqw_file,proj1,0.01,[-0.1,0.1],[-0.1,0.1],[-5,5]);
obj.assertPerformance(ts,test_fld_names{1},...
    'small memory based 1D cut in non-axis aligned direction 1');

ts = tic();
sqw2 = cut_sqw(obj.sqw_file,proj1,[-0.1,0.1],0.01,[-0.1,0.1],[-5,5]);
obj.assertPerformance(ts,test_fld_names{2},...
    'small memory based 1D cut in non-axis aligned direction 2');

ts = tic();
sqw3 = cut_sqw(obj.sqw_file,proj1,[-0.1,0.1],[-0.1,0.1],0.01,[-5,5]);
obj.assertPerformance(ts,test_fld_names{3},...
    'small memory based 1D cut in non-axis aligned direction 3');

ts = tic();
sqw4 = cut_sqw(obj.sqw_file,proj1,[-0.1,0.1],[-0.1,0.1],[-0.1,0.1],0.2);
perf_res=obj.assertPerformance(ts,test_fld_names{4},...
    'small memory based 1D cut along energy direction (q are not axis aligned)');
