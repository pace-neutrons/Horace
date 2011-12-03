%% ================================================================================================
%     Test mslice clasees
%  ================================================================================================
data_dir = 'T:\temp\mslice';
work_dir = 'c:\temp';


%% ================================================================================================
%     Test reading, writing
%  ================================================================================================

% Really need to compare the read in cuts and slices with the ones created directly from mslice.
% However, this is subject to a lot of changes in mslice, weird organisation of fields etc.

% Read in objects
% ----------------------------------------------------
% Read in the cuts and slices
mc_1=read(cut,fullfile(data_dir,'mc_1.cut'));
mc_2=read(cut,fullfile(data_dir,'mc_2.cut'));
mc_3a=read(cut,fullfile(data_dir,'mc_3a.cut'));
mc_3b=read(cut,fullfile(data_dir,'mc_3b.cut'));
mc_3c=read(cut,fullfile(data_dir,'mc_3c.cut'));

ms_1=read(slice,fullfile(data_dir,'ms_1.slc'));
ms_2=read(slice,fullfile(data_dir,'ms_2.slc'));
ms_3a=read(slice,fullfile(data_dir,'ms_3a.slc'));
ms_3b=read(slice,fullfile(data_dir,'ms_3b.slc'));
ms_3c=read(slice,fullfile(data_dir,'ms_3c.slc'));
ms_4=read(slice,fullfile(data_dir,'ms_4.slc'));

% Write them out and read them back in; 
save(mc_1,fullfile(work_dir,'mc_1.cut'));
save(mc_2,fullfile(work_dir,'mc_2.cut'));
save(mc_3a,fullfile(work_dir,'mc_3a.cut'));
save(mc_3b,fullfile(work_dir,'mc_3b.cut'));
save(mc_3c,fullfile(work_dir,'mc_3c.cut'));

save(ms_1,fullfile(work_dir,'ms_1.cut'));
save(ms_2,fullfile(work_dir,'ms_2.cut'));
save(ms_3a,fullfile(work_dir,'ms_3a.cut'));
save(ms_3b,fullfile(work_dir,'ms_3b.cut'));
save(ms_3c,fullfile(work_dir,'ms_3c.cut'));
save(ms_4,fullfile(work_dir,'ms_4.cut'));




%% ================================================================================================
%     Test reading, writing
%  ================================================================================================
add_spe([1,2],data_dir,{'s1.spe','s2.spe'},'s_add.spe');
combine_spe([1/3,2/3],data_dir,{'s1.spe','s2.spe'},'s_com.spe');
s_1=read_spe(fullfile(data_dir,'s1.spe'));
s_2=read_spe(fullfile(data_dir,'s2.spe'));
s_add=read_spe(fullfile(data_dir,'s_add.spe'));
s_com=read_spe(fullfile(data_dir,'s_com.spe'));

d_1=IXTdataset_2d(s_1);
d_2=IXTdataset_2d(s_2);
d_add=IXTdataset_2d(s_add);
d_com=IXTdataset_2d(s_com);

i_1=integrate_x(d_1,-5,5);
i_2=integrate_x(d_2,-5,5);
i_add=integrate_x(d_add,-5,5);
i_com=integrate_x(d_com,-5,5);
