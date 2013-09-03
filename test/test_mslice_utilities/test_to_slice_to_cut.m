function  test_to_slice_to_cut
% Test the functions that create slices and cuts from sqw objects made from a single spe file

banner_to_screen(mfilename)

data_dir=fullfile(fileparts(mfilename('fullpath')),'testdata');

% Read reference cuts and slices
s1q=read_cut(fullfile(data_dir,'s1q.cut'));
s1e=read_cut(fullfile(data_dir,'s1e.cut'));
s2qq=read_slice(fullfile(data_dir,'s2qq.slc'));
s2qe=read_slice(fullfile(data_dir,'s2qe.slc'));

% Read reference sqw object, convert to cuts and slices, write, read back in
% This avoids the problems from limits sig. figs. in the stored cuts and slices as ASCII files)
w1q=read_sqw(fullfile(data_dir,'w1q.sqw'));
w1e=read_sqw(fullfile(data_dir,'w1e.sqw'));
w2qq=read_sqw(fullfile(data_dir,'w2qq.sqw'));
w2qe=read_sqw(fullfile(data_dir,'w2qe.sqw'));

tmp=to_cut(w1q); save(tmp,fullfile(tempdir,'tmp.cut')); s1q_b=read_cut(fullfile(tempdir,'tmp.cut'));
tmp=to_cut(w1e); save(tmp,fullfile(tempdir,'tmp.cut')); s1e_b=read_cut(fullfile(tempdir,'tmp.cut'));
tmp=to_slice(w2qq); save(tmp,fullfile(tempdir,'tmp.slc')); s2qq_b=read_slice(fullfile(tempdir,'tmp.slc'));
tmp=to_slice(w2qe); save(tmp,fullfile(tempdir,'tmp.slc')); s2qe_b=read_slice(fullfile(tempdir,'tmp.slc'));

% Test equivalence
if ~equal_to_tol(s1q,s1q_b,-1e-10,'min_den',0.1,'ignore_str',1), error('Computed cut and saved cut are inequivalent'), end
if ~equal_to_tol(s1e,s1e_b,-1e-10,'min_den',0.1,'ignore_str',1), error('Computed cut and saved cut are inequivalent'), end
if ~equal_to_tol(s2qq,s2qq_b,-1e-6,'min_den',1,'ignore_str',1), error('Computed slice and saved slice are inequivalent'), end
if ~equal_to_tol(s2qe,s2qe_b,-1e-6,'min_den',1,'ignore_str',1), error('Computed slice and saved slice are inequivalent'), end

disp(' ')
disp(' All OK')
disp(' ')
