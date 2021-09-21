function perf_res = large_cut_pix_fbased_task_perfornance(obj,field_names_map)
hs = head_sqw(obj.sqw_file);

if horace_version('-num') < 400
    urng = hs.urange;
else
    urng = hs.img_db_range;
end
urng = range_add_border(urng,-1.e-4)';

test_fld_names = field_names_map('big_cut_filebased');
% test large 1 dimensional cuts, non-axis aligned, with whole
% integration. for big input sqw files this should go to
% file-based cuts
fls_2del = {'cutH1D_AllInt.sqw','cutK1D_AllInt.sqw',...
    'cutL1D_AllInt.sqw','cutE_AllInt.sqw'};
clob1 = onCleanup(@()obj.delete_files(fls_2del));
%profile on
ts = tic();
proj1 = struct('u',[1,0,0],'v',[0,1,1]);
cut_sqw(obj.sqw_file,proj1,0.01,urng(2,:),urng(3,:),urng(4,:),'cutH1D_AllInt.sqw');
obj.assertPerformance(ts,test_fld_names{1},...
    'large file-based 1D cut. Direction 1; Whole dataset integration along 3 other directions');
%profile off
%profile viewer
%stop
ts = tic();
cut_sqw(obj.sqw_file,proj1,urng(1,:),0.01,urng(3,:),urng(4,:),'cutK1D_AllInt.sqw');
obj.assertPerformance(ts,test_fld_names{2},...
    'large file-based 1D cut. Direction 2; Whole dataset integration along 3 other directions');

ts = tic();
cut_sqw(obj.sqw_file,proj1,urng(1,:),urng(2,:),0.01,urng(4,:),'cutL1D_AllInt.sqw');
obj.assertPerformance(ts,test_fld_names{3},...
    'large file-based 1D cut. Direction 3; Whole dataset integration along 3 other directions');

ts = tic();
cut_sqw(obj.sqw_file,proj1,urng(1,:),urng(2,:),urng(3,:),0.2,'cutE_AllInt.sqw');
perf_res=obj.assertPerformance(ts,test_fld_names{4},...
    'large file-based 1D cut. Energy direction; Whole dataset integration along 3 other directions');
