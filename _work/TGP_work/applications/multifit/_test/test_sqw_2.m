function test_sqw_2
% Test of multifit2 with sqw objects

%% ------------------------------------------------------------------------------------------------
% Example of fitting more than one sqw object
% -------------------------------------------------------------------------------------------------
mftest_dir = 'T:\SVN_area\Herbert_trunk\_work\TGP_work\applications\multifit\mftest';

% Read in data
% ------------
w1data=read_sqw(fullfile(mftest_dir,'data/w1data.sqw'));
w2data=read_sqw(fullfile(mftest_dir,'data/w2data.sqw'));


%% ------------------------------------------------------------------------------------------------
% Combine the two cuts into an array of sqw objects and fit
% ---------------------------------------------------------
% The data were created using the cross-section model that is fitted shortly,
% with parameters [5,5,1,20,0], random noise added and then a background of
% 0.01 and 0.02 to the first and second data sets. That is, when the fit is
% performed, we expect the results [5,5,1,20,0.01] and [5,5,1,20,0.02]

% Perform a fit that constrains the first two parameters (gap and J) to be
% the same in both data sets, but allow the intensity and gamma to vary
% independently. A constant background can also vary independently.



nrep=50;
win=[noisify(repmat(w1data,1,nrep),0.03),noisify(repmat(w2data,1,nrep),0.03)];

pin1 = [5,5,1.2,10,0];
pin2 = [5,5,1.4,15,0];
pin = [repmat({pin1},1,nrep),repmat({pin2},1,nrep)];

% *** Profile this line ***
[wfit_ref,fitpar_ref]=multifit_sqw_sqw(win, @sqw_bcc_hfm, [5,5,0,10,0], [1,1,0,0,0], @sqw_bcc_hfm, pin, [1,1,1,1,1], {{{1,1,0},{2,2,0}}});




% New multifit
% -----------------
% Simulate
kk = multifit2_sqw (win);
kk = kk.set_local_foreground;
kk = kk.set_fun (@sqw_bcc_hfm, pin);
kk = kk.set_bind ({1,[1,1]},{2,[2,1]});

[wfit,fitdata,ok,mess] = kk.fit;

if~isequaln(wfit_ref,wfit), error('*** Oh dear! ***'), end

