datafile='test_tobyfit_let_1_data.mat';
load(datafile, 'w1a', 'w1b');
efix = 8.04;
instru = let_instrument_obj_for_tests (efix, 280, 140, 20, 2, 2);
sample = IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.012,0.012,0.04]);
sample.alatt = [3.3000 3.3000 3.3000];
sample.angdeg = [90 90 90];

w1a = set_instrument (w1a, instru);
w1a = set_sample (w1a, sample);

w1b = set_instrument (w1b, instru);
w1b = set_sample (w1b, sample);

%wdata1 = [w1a,w1b];
wdata1 = [w1a];

% save('wdata1.mat')
% % 
% wdata1 = fullfile('wdata1.mat');

% amp=5000;    fwhh=0.2;
% 
% nlist = 0;
% datafile='wdata1.mat';
% load(datafile, 'w1a', 'w1b');
% 
% wdata1 = [w1a];

kk = tobyfit(wdata1);
kk = kk.set_local_foreground;
kk = kk.set_fun(@testfunc_nb_sqw);
kk = kk.set_pin({[amp,fwhh]});
% kk = kk.set_bind({2,[2,1]});
% kk = kk.set_bfun(@testfunc_bkgd,[0,0]);
kk = kk.set_mc_points(2);
%kk = kk.set_options('listing',nlist);
tic()
[wfit_1,fitpar_1] = kk.fit();
toc()
wfit_1,fitpar_1

[spinw_y, e, msk] = sigvar_get(wfit_1);

%spinw_y(msk==1)






