% Assumes have created a data file
S=load('testdata_multifit_1.mat');

SS.warr3 = [S.w1,S.w2,S.w3];
SS.sarr3 = [S.wstruct1,S.wstruct2,S.wstruct3];

% An exanple fit with old multifit
[wfit_ref,fitdata_ref] = multifit (SS.sarr3, @mftest_gauss, [100,45,10], @mftest_bkgd, [0,0], 'list', 2);

% Same with mfclass
kk = mfclass(SS.sarr3);
kk = kk.set_fun (@mftest_gauss, [100,45,10]);
kk = kk.set_bfun (@mftest_bkgd, [0,0]);
kk = kk.set_option('listing',2);

[wfit, fitdata] = kk.fit;








