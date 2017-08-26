%% Set up locations of data sources
data200='E:\data\Fe\sqw_Alex\Fe_ei200.sqw';
data400='E:\data\Fe\sqw_Alex\Fe_ei401.sqw';
data800='E:\data\Fe\sqw_Alex\Fe_ei787.sqw';
data1400='E:\data\Fe\sqw_Alex\Fe_ei1371_base.sqw';

%% -----------------------------------------------------------------------------
%  Reference const-E cut to see accesible phase space
% -----------------------------------------------------------------------------
proj110.u = [1,1,0];
proj110.v = [-1,1,0];
w2_1 = cut_sqw (data800, proj110, [-2,0.05,4], [-2,0.05,4], [-0.1,0.1], [150,170], '-nopix');
w2_2 = cut_sqw (data800, proj110, [1,0.05,2], [1,0.05,2], [-0.1,0.1], [150,170], '-nopix');
w2_3 = cut_sqw (data800, proj110, [1,0.05,2], [1,0.05,2], [-0.1,0.1], [150,170], '-nopix');



% 1D dnd:
% -------
proj110.u = [1,1,0];
proj110.v = [-1,1,0];
w1_1 = cut_sqw (data800, proj110, [-0.5,0.05,2.5], [-0.1,0],   [-0.1,0.1], [150,170], '-nopix');
w1_2 = cut_sqw (data800, proj110, [-0.5,0.05,2.5], [-0.2,-0.1],[-0.1,0.1], [150,170], '-nopix');
w1_3 = cut_sqw (data800, proj110, [-0.5,0.05,2.5], [-0.3,-0.2],[-0.1,0.1], [150,170], '-nopix');

w1_tot = cut_sqw (data800, proj110, [-0.5,0.05,2.5], [-0.3,0],   [-0.1,0.1], [150,170], '-nopix');

w1_tmp = combine_dnd_same_bins (w1_1,w1_2,w1_3);



% 1D sqw:
% -------
proj110.u = [1,1,0];
proj110.v = [-1,1,0];
s1_1 = cut_sqw (data800, proj110, [-0.5,0.05,2.5], [-0.1,0],   [-0.1,0.1], [150,170]);
s1_2 = cut_sqw (data800, proj110, [-0.5,0.05,2.5], [-0.25,-0.05],[-0.1,0.1], [150,170]);
s1_3 = cut_sqw (data800, proj110, [-0.5,0.05,2.5], [-0.3,-0.2],[-0.1,0.1], [150,170]);

s1_tot = cut_sqw (data800, proj110, [-0.5,0.05,2.5], [-0.3,0],   [-0.1,0.1], [150,170]);

s1_tmp = combine_sqw_same_bins (s1_1,s1_2,s1_3);


%% ==========================================================================
% Test symmetrisation

%  Reference const-E cut to see accesible phase space
% -----------------------------------------------------------------------------
proj100.u = [1,0,0];
proj100.v = [0,1,0];
wce = cut_sqw (data800, proj100, 0.05, 0.05, [-0.1,0.1], [150,170], '-nopix');
plot(wce)
keep_figure
lx -2 3
ly -2 4
lz 0 0.3


%  The classic cut
% -----------------------------------------------------------------------------
proj110.u = [1,1,0];
proj110.v = [-1,1,0];

w2_110 = cut_sqw (data800, proj110, [0.8,1.2], 0.05, [-0.2,0.2], [0,0,500], '-nopix');
wback = cut(w2_110,[3,4],[]);
wcor_110 = cut_correct (w2_110,wback);


%  Test symmetrisation
% -----------------------------------------------------------------------------

pix_opt = {'-nopix'};
%pix_opt = {};

proj110.u = [1,-1,0];
proj110.v = [1,1,0];
w2_110a = cut_sqw (data800, proj110, [-3,0.05,3], [0.8,1.2], [-0.2,0.2], [0,0,500], pix_opt{:});

proj110.u = [1,-1,0];
proj110.v = [1,1,0];
w2_110b = cut_sqw (data800, proj110, [0.8,1.2], [-3,0.05,3], [-0.2,0.2], [0,0,500], pix_opt{:});


s1 = symop([1,0,0],[0,0,1],[2,0,0]);
w2_tot = cut_sqw_sym (data800, proj110, [-3,0.05,3], [0.8,1.2], [-0.2,0.2], [0,0,500], s1, pix_opt{:});
wcor_tot = cut_correct (w2_tot,wback);

%--------------------------------------------------------------
% A real cut...

% l=0 plane
% ---------
w2_110_m110 = cut_quick (data800, [1,1,0], [-1,1,0], [1,1,0], 0.05, 0.5, [0,0,500]);
w2c_110_m110 = cut_correct (w2_110_m110,wback);
plot(w2c_110_m110); lx -3 3; lz 0 0.5; keep_figure

rlp = [1,1,0];
u = [-1,1,0]; v = [1,1,0]; bin = [0,0.05,3]; width = 0.5; ebins = [0,0,500];
ww1 = cut_quick (data800, rlp, u, v, bin, width, ebins);
wc1 = cut_correct (ww1,wback);
plot(wc1); lx -3 3; lz 0 0.5; keep_figure

sref_v = symop([0,1,0],[0,0,1],[0,2,0]);
sref_h = symop([1,0,0],[0,1,0],[0,2,0]);
srot90 = symop([0,1,0],90,[0,2,0]);
sdiag = symop([1,1,0],[0,0,1]);

sym = sref_v;
sym = {sref_v,srot90,[srot90,sref_h]};
sym = {sref_v,srot90,[srot90,sref_h],sdiag,[sdiag,sref_v],[sdiag,srot90],[sdiag,srot90,sref_h]};

ww2 = cut_quick_sym (data800, rlp, u, v, bin, width, ebins, sym);
wc2 = cut_correct (ww2,wback);
plot(wc2); lx -3 3; lz 0 0.5; keep_figure

ww3 = cut_quick_sym (data800, rlp, u, v, [0,0.025,3], width, ebins, sym);
wc3 = cut_correct (ww3,wback);
plot(wc3); lx -3 3; lz 0 0.5; keep_figure





