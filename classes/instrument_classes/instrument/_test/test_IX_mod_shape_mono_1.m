efix=8;
make_msm = @(x)IX_mod_shape_mono(x.moderator,x.chop_shape,x.chop_mono);

%old_covariance = @(x)covariance_mod_shape_mono (x.moderator,x.chop_shape,x.chop_mono,efix);

% mod FWHH=99.37us, shape_chop FWHH=66.48us
% ------------------------------------------------------
% Will have pulse determined by moderator
instru_mod = let_instrument_for_tests (efix, 280, 140, 20, 2, 2);
instru_mod.chop_shape.frequency=171;
msm_mod = make_msm(instru_mod);
msm_mod.energy = efix;

bigtic
[tcov,tmean] = msm_mod.covariance;
bigtoc
disp(tmean), disp([tcov(1,1), tcov(2,2), tcov(1,2)])


% mod FWHH=99.37us, shape_chop FWHH=66.09us
% ------------------------------------------------------
% Will have pulse determined by shaping chopper
instru_shape = let_instrument_for_tests (efix, 280, 140, 20, 2, 2);
instru_shape.chop_shape.frequency=172;
msm_shape = make_msm(instru_shape);
msm_shape.energy = efix;

bigtic
[tcov,tmean] = msm_shape.covariance;
bigtoc
disp(tmean), disp([tcov(1,1), tcov(2,2), tcov(1,2)])


% mod FWHH=33947us, shape_chop FWHH=66.48us
% ------------------------------------------------------
instru_shape_only = let_instrument_for_tests (efix, 280, 140, 20, 2, 2);
instru_shape_only.moderator.pp(1)=10000;
instru_shape_only.chop_shape.frequency=171;
msm_shape_only = make_msm(instru_shape_only);
msm_shape_only.energy = efix;

bigtic
[tcov,tmean] = msm_shape_only.covariance;
bigtoc
disp(tmean), disp([tcov(1,1), tcov(2,2), tcov(1,2)])


% mod FWHH=99.37us, shape_chop FWHH=11368us
% ------------------------------------------------------
instru_mod_only = let_instrument_for_tests (efix, 280, 140, 20, 2, 2);
instru_mod_only.chop_shape.frequency=1;
msm_mod_only = make_msm(instru_mod_only);
msm_mod_only.energy = efix;

bigtic
[tcov,tmean] = msm_mod_only.covariance;
bigtoc
disp(tmean), disp([tcov(1,1), tcov(2,2), tcov(1,2)])



% ------------------------------------------------------
% Will have pulse determined by moderator in 1e-5 covariance calculation
instru_mod = let_instrument_for_tests (efix, 280, 140, 20, 2, 2);
instru_mod.chop_shape.frequency=32.543;
msm_mod = make_msm(instru_mod);
msm_mod.energy = efix;

bigtic
[tcov,tmean] = msm_mod.covariance;
bigtoc
disp(tmean), disp([tcov(1,1), tcov(2,2), tcov(1,2)])


% Will have pulse determined by shaping chopper in 1e-5 covariance calculation
instru_mod = let_instrument_for_tests (efix, 280, 140, 20, 2, 2);
instru_mod.chop_shape.frequency=32.544;
msm_mod = make_msm(instru_mod);
msm_mod.energy = efix;

bigtic
[tcov,tmean] = msm_mod.covariance;
bigtoc
disp(tmean), disp([tcov(1,1), tcov(2,2), tcov(1,2)])




