% Test the legacy format
test_dir = 'T:\SVN_Area\Herbert_trunk\_work\TGP_work\applications\multifit\_test';
S=load(fullfile(test_dir,'/data/testdata_multifit_1.mat'));

% Data for the test
warr3 = [S.w1,S.w2,S.w3];
nlist = 1;



%------------------------------------------------------------------------------
%------------------------------------------------------------------------------
% Setup
% ------

% Put standard multifit on the path
warn_state=warning('off','all');
rmpath('T:\SVN_Area\Herbert_trunk\applications\multifit_legacy')
try
    mfclass_off
catch
end
addpath('T:\SVN_Area\Herbert_trunk\applications\multifit')
warning(warn_state);



% Original multifit
% --------------------------------------------------------------------
% Ensure fit control parameters are the same for old and new multifit
fcp = [0.0001 30 0.0001];

% An exanple fit with old multifit
[wfit_ref0,fitdata_ref0] = multifit (warr3,...
    @mftest_gauss, [100,45,10], @mftest_bkgd, {[10,0],[20,0],[30,0]},...
    'fitcontrolparameters',fcp,...
    'list', nlist);



%------------------------------------------------------------------------------
%------------------------------------------------------------------------------
% Setup
% ------

herbert   = fileparts(which('herbert_init'));
mfclass_dir = fullfile(herbert,'_work/TGP_work/applications/multifit');
warn_state=warning('off','all');
rmpath('T:\SVN_Area\Herbert_trunk\applications\multifit')
try
    start_app ('mfclass',mfclass_dir)
catch
    error('Cannot start mfclass')
end
addpath('T:\SVN_Area\Herbert_trunk\applications\multifit_legacy')
warning(warn_state);



% Legacy multifit
% --------------------------------------------------------------------
% Ensure fit control parameters are the same for old and new multifit
fcp = [0.0001 30 0.0001];

% An exanple fit with old multifit
[wfit_ref,fitdata_ref] = multifit2 (warr3,...
    @mftest_gauss, [100,45,10], @mftest_bkgd, {[10,0],[20,0],[30,0]},...
    'fitcontrolparameters',fcp,...
    'list', nlist);


if ~isequaln(wfit_ref,wfit_ref0) || ~isequaln(fitdata_ref,fitdata_ref0)
    error('Not equal fits')
end



% Same with mfclass
% -------------------
kk = multifit2(warr3);
kk = kk.set_fun (@mftest_gauss, [100,45,10]);
kk = kk.set_bfun (@mftest_bkgd, {[10,0],[20,0],[30,0]});
kk = kk.set_options('fit_control_parameters',fcp);
kk = kk.set_options('listing',nlist);

[wcalc, fitcalc] = kk.simulate;

[wfit, fitdata] = kk.fit;


if ~isequaln(wfit_ref0,wfit) || ~isequaln(fitdata_ref0,fitdata)
    error('Not equal fits')
end
