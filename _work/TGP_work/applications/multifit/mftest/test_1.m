% Assumes have created a data file
S=load('./data/testdata_multifit_1.mat');


%--------------------------------------------------------------------------------------------------------------------
SS.warr3 = [S.w1,S.w2,S.w3];
SS.sarr3 = [S.wstruct1,S.wstruct2,S.wstruct3];

% An exanple fit with old multifit
[wfit_ref,fitdata_ref] = multifit (IX_to_struct(SS.warr3), @mftest_gauss, [100,45,10], @mftest_bkgd, {[10,0],[20,0],[30,0]}, 'list', 2);
wfit_ref = struct_to_IX(wfit_ref);

% Same with mfclass
kk = mfclass(IX_to_struct(SS.warr3));
kk = kk.set_fun (@mftest_gauss, [100,45,10]);
kk = kk.set_bfun (@mftest_bkgd, {[10,0],[20,0],[30,0]});
kk = kk.set_option('listing',2);

[wcalc, fitcalc] = kk.simulate;
wcalc = struct_to_IX(wcalc);

[wfit, fitdata] = kk.fit;
wfit = struct_to_IX(wfit);

if ~isequaln(wfit_ref,wfit) || ~isequaln(fitdata_ref,fitdata)
    error('Not equal fits')
end

% Check parameter transfer feature
[wcalcfit, fitcalc] = kk.simulate(fitdata);
wcalcfit = struct_to_IX(wcalcfit);



