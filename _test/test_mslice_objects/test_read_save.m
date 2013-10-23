function test_read_save
% Test reading and saving of mslice classes
%
%   >> test_read_save
%
% Author: T.G.Perring

banner_to_screen(mfilename)

% Unpack test objects to test area
% --------------------------------
unpack_data_files
ref_dir=tempdir;

% Read in objects
% ----------------------------------------------------
% Read in the cuts, slices and spe files
% (Should really have these in a mat file, so that they are independent of the read method)
mc_1_ref =read(cut,fullfile(ref_dir,'mc_1.cut'));
mc_2_ref =read(cut,fullfile(ref_dir,'mc_2.cut'));
mc_3a_ref=read(cut,fullfile(ref_dir,'mc_3a.cut'));
mc_3b_ref=read(cut,fullfile(ref_dir,'mc_3b.cut'));
mc_3c_ref=read(cut,fullfile(ref_dir,'mc_3c.cut'));

ms_1_ref =read(slice,fullfile(ref_dir,'ms_1.slc'));
ms_2_ref =read(slice,fullfile(ref_dir,'ms_2.slc'));
ms_3a_ref=read(slice,fullfile(ref_dir,'ms_3a.slc'));
ms_3b_ref=read(slice,fullfile(ref_dir,'ms_3b.slc'));
ms_3c_ref=read(slice,fullfile(ref_dir,'ms_3c.slc'));
ms_4_ref =read(slice,fullfile(ref_dir,'ms_4.slc'));

s1_ref=read(spe,fullfile(ref_dir,'s1.spe'));
s2_ref=read(spe,fullfile(ref_dir,'s2.spe'));
s_add_ref=read(spe,fullfile(ref_dir,'s_add.spe'));
s_com_ref=read(spe,fullfile(ref_dir,'s_com.spe'));

% Write them out and read them back in; this at least tests the consistency of read and save
save(mc_1_ref,fullfile(ref_dir,'mc_1_tmp.cut'));
save(mc_2_ref,fullfile(ref_dir,'mc_2_tmp.cut'));
save(mc_3a_ref,fullfile(ref_dir,'mc_3a_tmp.cut'));
save(mc_3b_ref,fullfile(ref_dir,'mc_3b_tmp.cut'));
save(mc_3c_ref,fullfile(ref_dir,'mc_3c_tmp.cut'));

save(ms_1_ref,fullfile(ref_dir,'ms_1_tmp.slc'));
save(ms_2_ref,fullfile(ref_dir,'ms_2_tmp.slc'));
save(ms_3a_ref,fullfile(ref_dir,'ms_3a_tmp.slc'));
save(ms_3b_ref,fullfile(ref_dir,'ms_3b_tmp.slc'));
save(ms_3c_ref,fullfile(ref_dir,'ms_3c_tmp.slc'));
save(ms_4_ref,fullfile(ref_dir,'ms_4_tmp.slc'));

save(s1_ref,fullfile(ref_dir,'s1_tmp.spe'));
save(s2_ref,fullfile(ref_dir,'s2_tmp.spe'));
save(s_add_ref,fullfile(ref_dir,'s_add_tmp.spe'));
save(s_com_ref,fullfile(ref_dir,'s_com_tmp.spe'));

mc_1=read(cut,fullfile(ref_dir,'mc_1_tmp.cut'));
mc_2=read(cut,fullfile(ref_dir,'mc_2_tmp.cut'));
mc_3a=read(cut,fullfile(ref_dir,'mc_3a_tmp.cut'));
mc_3b=read(cut,fullfile(ref_dir,'mc_3b_tmp.cut'));
mc_3c=read(cut,fullfile(ref_dir,'mc_3c_tmp.cut'));

ms_1=read(slice,fullfile(ref_dir,'ms_1_tmp.slc'));
ms_2=read(slice,fullfile(ref_dir,'ms_2_tmp.slc'));
ms_3a=read(slice,fullfile(ref_dir,'ms_3a_tmp.slc'));
ms_3b=read(slice,fullfile(ref_dir,'ms_3b_tmp.slc'));
ms_3c=read(slice,fullfile(ref_dir,'ms_3c_tmp.slc'));
ms_4=read(slice,fullfile(ref_dir,'ms_4_tmp.slc'));

s1=read(spe,fullfile(ref_dir,'s1_tmp.spe'));
s2=read(spe,fullfile(ref_dir,'s2_tmp.spe'));
s_add=read(spe,fullfile(ref_dir,'s_add_tmp.spe'));
s_com=read(spe,fullfile(ref_dir,'s_com_tmp.spe'));

% Check equivalence
% -----------------
if ~equivalent_mslice_objects(mc_1_ref,mc_1),   assertTrue(false,'mc_1_ref, mc_1  not equivalent'), end
if ~equivalent_mslice_objects(mc_2_ref,mc_2),   assertTrue(false,'mc_2_ref, mc_2  not equivalent'), end
if ~equivalent_mslice_objects(mc_3a_ref,mc_3a), assertTrue(false,'mc_3a_ref, mc_3a  not equivalent'), end
if ~equivalent_mslice_objects(mc_3b_ref,mc_3b), assertTrue(false,'mc_3b_ref, mc_3b  not equivalent'), end
if ~equivalent_mslice_objects(mc_3c_ref,mc_3c), assertTrue(false,'mc_3c_ref, mc_3c  not equivalent'), end

if ~equivalent_mslice_objects(ms_1_ref,ms_1),   assertTrue(false,'ms_1_ref, ms_1  not equivalent'), end
if ~equivalent_mslice_objects(ms_2_ref,ms_2),   assertTrue(false,'ms_2_ref, ms_2  not equivalent'), end
if ~equivalent_mslice_objects(ms_3a_ref,ms_3a), assertTrue(false,'ms_3a_ref, ms_3a  not equivalent'), end
if ~equivalent_mslice_objects(ms_3b_ref,ms_3b), assertTrue(false,'ms_3b_ref, ms_3b  not equivalent'), end
if ~equivalent_mslice_objects(ms_3c_ref,ms_3c), assertTrue(false,'ms_3c_ref, ms_3c  not equivalent'), end
if ~equivalent_mslice_objects(ms_4_ref,ms_4),   assertTrue(false,'ms_4_ref, ms_4  not equivalent'), end

if ~equivalent_mslice_objects(s1_ref,s1), assertTrue(false,'s1_ref, s1  not equivalent'), end
if ~equivalent_mslice_objects(s2_ref,s2), assertTrue(false,'s2_ref, s2  not equivalent'), end
if ~equivalent_mslice_objects(s_add_ref,s_add), assertTrue(false,'s_add_ref, s_add  not equivalent'), end
if ~equivalent_mslice_objects(s_com_ref,s_com), assertTrue(false,'s_com_ref, s_com  not equivalent'), end


% Success announcement
% --------------------
banner_to_screen([mfilename,': Test(s) passed'],'bot')
