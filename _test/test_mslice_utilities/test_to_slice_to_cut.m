function  test_to_slice_to_cut
% Test the functions that create slices and cuts from sqw objects made from a single spe file
%
%   >> test_to_slice_to_cut
%
% Author: T.G.Perring

banner_to_screen(mfilename)

% Unpack data files
rootpath=fileparts(mfilename('fullpath'));
flnames=unzip(fullfile(rootpath,'testdata_mslice_utilities.zip'),tmp_dir);

% Read reference cuts and slices
s1q=read_cut(fullfile(tmp_dir,'s1q.cut'));
s1e=read_cut(fullfile(tmp_dir,'s1e.cut'));
s2qq=read_slice(fullfile(tmp_dir,'s2qq.slc'));
s2qe=read_slice(fullfile(tmp_dir,'s2qe.slc'));

% Read reference sqw object, convert to cuts and slices, write, read back in
% This avoids the problems from limits sig. figs. in the stored cuts and slices as ASCII files)
w1q=read_sqw(fullfile(tmp_dir,'w1q.sqw'));
w1e=read_sqw(fullfile(tmp_dir,'w1e.sqw'));
w2qq=read_sqw(fullfile(tmp_dir,'w2qq.sqw'));
w2qe=read_sqw(fullfile(tmp_dir,'w2qe.sqw'));

tmp=to_cut(w1q); save(tmp,fullfile(tmp_dir,'tmp.cut')); s1q_b=read_cut(fullfile(tmp_dir,'tmp.cut'));
tmp=to_cut(w1e); save(tmp,fullfile(tmp_dir,'tmp.cut')); s1e_b=read_cut(fullfile(tmp_dir,'tmp.cut'));
tmp=to_slice(w2qq); save(tmp,fullfile(tmp_dir,'tmp.slc')); s2qq_b=read_slice(fullfile(tmp_dir,'tmp.slc'));
tmp=to_slice(w2qe); save(tmp,fullfile(tmp_dir,'tmp.slc')); s2qe_b=read_slice(fullfile(tmp_dir,'tmp.slc'));

% Test equivalence
if ~equal_to_tol(s1q,s1q_b,-1e-10,'min_den',0.1,'ignore_str',1), assertTrue(false,'Computed cut and saved cut are inequivalent'), end
if ~equal_to_tol(s1e,s1e_b,-1e-10,'min_den',0.1,'ignore_str',1), assertTrue(false,'Computed cut and saved cut are inequivalent'), end
if ~equal_to_tol(s2qq,s2qq_b,-2e-6,'min_den',1,'ignore_str',1), assertTrue(false,'Computed slice and saved slice are inequivalent'), end
if ~equal_to_tol(s2qe,s2qe_b,-2e-6,'min_den',1,'ignore_str',1), assertTrue(false,'Computed slice and saved slice are inequivalent'), end

% Delete data files
delete_ok=true;
flnames=[flnames,{fullfile(tmp_dir,'tmp.cut'),fullfile(tmp_dir,'tmp.slc')}];
for i=1:numel(flnames)
    try
        delete(flnames{i});
    catch
        if delete_ok==true
            disp('Unable to delete one or more temporary files')
            delete_ok=false;
        end
    end
end

% Success announcement
% --------------------
banner_to_screen([mfilename,': Test(s) passed'],'bot')
