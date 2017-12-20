function test_1
% Test of multifit2 with structures

nlist = 0;  % set to 1 or 2 for listing during fit

% Assumes have created a data file
test_dir = fileparts(mfilename('fullpath'));
S=load(fullfile(test_dir,'/data/testdata_multifit_1.mat'));

%------------------------------------------------------------------------------
SS.warr3 = [S.w1,S.w2,S.w3];

% Ensure fit control parameters are the same for old and new multifit
fcp = [0.0001 30 0.0001];

% An exanple fit with old multifit
[wfit_ref,fitdata_ref] = multifit (IX_to_struct(SS.warr3),...
    @mftest_gauss, [100,45,10], @mftest_bkgd, {[10,0],[20,0],[30,0]},...
    'fitcontrolparameters',fcp,...
    'list', nlist);
wfit_ref = struct_to_IX(wfit_ref);

% Same with mfclass
kk = mfclass(IX_to_struct(SS.warr3));
kk = kk.set_fun (@mftest_gauss, [100,45,10]);
kk = kk.set_bfun (@mftest_bkgd, {[10,0],[20,0],[30,0]});
kk = kk.set_options('fit_control_parameters',fcp);
kk = kk.set_options('listing',nlist);

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
