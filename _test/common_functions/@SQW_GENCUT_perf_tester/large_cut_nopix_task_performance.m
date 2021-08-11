function  [perf_res,sqw1,sqw2,sqw3,sqw4] = large_cut_nopix_task_performance(obj)

test_fld_names = field_names_map('big_cut_nopix');

hs = head_sqw(obj.sqw_file);
urng = hs.urange';


ts = tic();
proj1 = struct('u',[1,0,0],'v',[0,1,1]);
sqw1=cut_sqw(obj.sqw_file,proj1,0.01,urng(2,:),urng(3,:),urng(4,:),'-nopix');
obj.assertPerformance(ts,test_fld_names{1},...
    'large 1D cut direction 1 with whole dataset integration along 3 other directions. -nopix mode');

ts = tic();
sqw2=cut_sqw(obj.sqw_file,proj1,urng(1,:),0.01,urng(3,:),urng(4,:),'-nopix');
obj.assertPerformance(ts,test_fld_names{2},...
    'large 1D cut direction 2 with whole dataset integration along 3 other directions. -nopix mode');

ts = tic();
sqw3=cut_sqw(obj.sqw_file,proj1,urng(1,:),urng(2,:),0.01,urng(4,:),'-nopix');
obj.assertPerformance(ts, test_fld_names{3},...
    'large 1D cut direction 3 with whole dataset integration along 3 other directions. -nopix mode');

ts = tic();
sqw4=cut_sqw(obj.sqw_file,proj1,urng(1,:),urng(2,:),urng(3,:),0.2,'-nopix');

perf_res=obj.assertPerformance(ts, test_fld_names{4},...
    'large 1D cut along energy direction with whole dataset integration along 3 other directions. -nopix mode');
