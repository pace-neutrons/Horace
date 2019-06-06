% Test new normalisation of Horace cuts
% -------------------------------------

data_dir = 'D:\data\Fe\sqw_Toby';
cut_dir = 'T:\experiments\Fe\analysis_2017_05\matlab\cuts';

data800=fullfile(data_dir,'Fe_ei787.sqw');

proj100.u = [1,0,0];
proj100.v = [0,1,0];
wce = cut_sqw (data800, proj100, 0.05, 0.05, [-0.1,0.1], [150,170], '-nopix');
plot(wce)
keep_figure
lx -2 3
ly -2 4
lz 0 0.3


proj_1 = projaxes([2,0,0], [0,3,0], 'type', 'ppr');
wce_1 = cut_sqw (data800, proj_1, 0.05, 0.05, [-0.1,0.1], [150,170], '-nopix');
plot(wce_1)
keep_figure
lx -2 3
ly -2 4
lz 0 0.3


proj_1 = projaxes([2,0,0], [0,3,0], 'type', 'rrr');
wce_1 = cut_sqw (data800, proj_1, 0.05, 0.05, [-0.1,0.1], [150,170], '-nopix');
plot(wce_1)
keep_figure
lx -2 3
ly -2 4
lz 0 0.3


