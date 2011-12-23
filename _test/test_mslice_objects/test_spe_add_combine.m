%% ================================================================================================
%     Test mslice clasees
%  ================================================================================================
test_dir = 'c:\temp\test_mslice';

ref_dir=[test_dir,filesep,'ref'];
work_dir=[test_dir,filesep,'work'];
if~exist(ref_dir,'dir'), mkdir(ref_dir); end
if~exist(work_dir,'dir'), mkdir(work_dir); end

% Unpack test objects to test area
unpack_data_files(ref_dir)

%% ================================================================================================
%     Test reading, writing
%  ================================================================================================
clear mc_1_ref mc_2_ref mc_3a_ref mc_3b_ref mc_3c_ref
clear ms_1_ref ms_2_ref ms_3a_ref ms_3b_ref ms_3c_ref ms_4_ref
clear s1_ref s2_ref s_add_ref s_com_ref sbig_ref

clear mc_1 mc_2 mc_3a mc_3b mc_3c
clear ms_1 ms_2 ms_3a ms_3b ms_3c ms_4
clear s1 s2 s_add s_com sbig


% Read in objects
% ----------------------------------------------------
% Read in the cuts and slices
% Should really have these in a mat file, so that they are independent of the read method
mc_1_ref=read(cut,fullfile(ref_dir,'mc_1.cut'));
mc_2_ref=read(cut,fullfile(ref_dir,'mc_2.cut'));
mc_3a_ref=read(cut,fullfile(ref_dir,'mc_3a.cut'));
mc_3b_ref=read(cut,fullfile(ref_dir,'mc_3b.cut'));
mc_3c_ref=read(cut,fullfile(ref_dir,'mc_3c.cut'));

ms_1_ref=read(slice,fullfile(ref_dir,'ms_1.slc'));
ms_2_ref=read(slice,fullfile(ref_dir,'ms_2.slc'));
ms_3a_ref=read(slice,fullfile(ref_dir,'ms_3a.slc'));
ms_3b_ref=read(slice,fullfile(ref_dir,'ms_3b.slc'));
ms_3c_ref=read(slice,fullfile(ref_dir,'ms_3c.slc'));
ms_4_ref=read(slice,fullfile(ref_dir,'ms_4.slc'));

s1_ref=read(spe,fullfile(ref_dir,'s1.spe'));
s2_ref=read(spe,fullfile(ref_dir,'s2.spe'));
s_add_ref=read(spe,fullfile(ref_dir,'s_add.spe'));
s_com_ref=read(spe,fullfile(ref_dir,'s_com.spe'));
sbig_ref=read(spe,fullfile(ref_dir,'EI_400-PSI_0-BASE.SPE'));

% Write them out and read them back in; this at least tests the consistency of read and save
save(mc_1_ref,fullfile(work_dir,'mc_1.cut'));
save(mc_2_ref,fullfile(work_dir,'mc_2.cut'));
save(mc_3a_ref,fullfile(work_dir,'mc_3a.cut'));
save(mc_3b_ref,fullfile(work_dir,'mc_3b.cut'));
save(mc_3c_ref,fullfile(work_dir,'mc_3c.cut'));

save(ms_1_ref,fullfile(work_dir,'ms_1.slc'));
save(ms_2_ref,fullfile(work_dir,'ms_2.slc'));
save(ms_3a_ref,fullfile(work_dir,'ms_3a.slc'));
save(ms_3b_ref,fullfile(work_dir,'ms_3b.slc'));
save(ms_3c_ref,fullfile(work_dir,'ms_3c.slc'));
save(ms_4_ref,fullfile(work_dir,'ms_4.slc'));

save(s1_ref,fullfile(work_dir,'s1.spe'));
save(s2_ref,fullfile(work_dir,'s2.spe'));
save(s_add_ref,fullfile(work_dir,'s_add.spe'));
save(s_com_ref,fullfile(work_dir,'s_com.spe'));
save(sbig_ref,fullfile(work_dir,'EI_400-PSI_0-BASE.SPE'));

mc_1=read(cut,fullfile(work_dir,'mc_1.cut'));
mc_2=read(cut,fullfile(work_dir,'mc_2.cut'));
mc_3a=read(cut,fullfile(work_dir,'mc_3a.cut'));
mc_3b=read(cut,fullfile(work_dir,'mc_3b.cut'));
mc_3c=read(cut,fullfile(work_dir,'mc_3c.cut'));

ms_1=read(slice,fullfile(work_dir,'ms_1.slc'));
ms_2=read(slice,fullfile(work_dir,'ms_2.slc'));
ms_3a=read(slice,fullfile(work_dir,'ms_3a.slc'));
ms_3b=read(slice,fullfile(work_dir,'ms_3b.slc'));
ms_3c=read(slice,fullfile(work_dir,'ms_3c.slc'));
ms_4=read(slice,fullfile(work_dir,'ms_4.slc'));

s1=read(spe,fullfile(work_dir,'s1.spe'));
s2=read(spe,fullfile(work_dir,'s2.spe'));
s_add=read(spe,fullfile(work_dir,'s_add.spe'));
s_com=read(spe,fullfile(work_dir,'s_com.spe'));
sbig=read(spe,fullfile(work_dir,'EI_400-PSI_0-BASE.SPE'));

clear mc_1 mc_2 mc_3a mc_3b mc_3c
clear ms_1 ms_2 ms_3a ms_3b ms_3c ms_4
clear s1 s2 s_add s_com sbig
% Check equivalence
if ~equivalent_mslice_objects(mc_1_ref,mc_1),   disp('mc_1_ref, mc_1  not equivalent'), end
if ~equivalent_mslice_objects(mc_2_ref,mc_2),   disp('mc_2_ref, mc_2  not equivalent'), end
if ~equivalent_mslice_objects(mc_3a_ref,mc_3a), disp('mc_3a_ref, mc_3a  not equivalent'), end
if ~equivalent_mslice_objects(mc_3b_ref,mc_3b), disp('mc_3b_ref, mc_3b  not equivalent'), end
if ~equivalent_mslice_objects(mc_3c_ref,mc_3c), disp('mc_3c_ref, mc_3c  not equivalent'), end

if ~equivalent_mslice_objects(ms_1_ref,ms_1),   disp('ms_1_ref, ms_1  not equivalent'), end
if ~equivalent_mslice_objects(ms_2_ref,ms_2),   disp('ms_2_ref, ms_2  not equivalent'), end
if ~equivalent_mslice_objects(ms_3a_ref,ms_3a), disp('ms_3a_ref, ms_3a  not equivalent'), end
if ~equivalent_mslice_objects(ms_3b_ref,ms_3b), disp('ms_3b_ref, ms_3b  not equivalent'), end
if ~equivalent_mslice_objects(ms_3c_ref,ms_3c), disp('ms_3c_ref, ms_3c  not equivalent'), end
if ~equivalent_mslice_objects(ms_4_ref,ms_4),   disp('ms_4_ref, ms_4  not equivalent'), end

if ~equivalent_mslice_objects(s1_ref,s1), disp('s1_ref, s1  not equivalent'), end
if ~equivalent_mslice_objects(s2_ref,s2), disp('s2_ref, s2  not equivalent'), end
if ~equivalent_mslice_objects(s_add_ref,s_add), disp('s_add_ref, s_add  not equivalent'), end
if ~equivalent_mslice_objects(s_com_ref,s_com), disp('s_com_ref, s_com  not equivalent'), end
if ~equivalent_mslice_objects(sbig_ref,sbig), disp('sbig_ref, sbig  not equivalent'), end


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
