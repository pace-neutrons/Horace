function test_sqw_1
% Test of multifit2 with sqw objects

%% ------------------------------------------------------------------------------------------------
% Example of fitting more than one sqw object
% -------------------------------------------------------------------------------------------------
test_dir = fileparts(mfilename('fullpath'));

% Read in data
% ------------
w1data=read_sqw(fullfile(test_dir,'data/w1data.sqw'));
w2data=read_sqw(fullfile(test_dir,'data/w2data.sqw'));


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

win=[w1data,w2data];

% Original multifit
% -----------------
% Simulate
[wcalc_ref,calcpar_ref]=multifit_sqw_sqw(win, @sqw_bcc_hfm, [5,5,0,10,0], [1,1,0,0,0],...
    @sqw_bcc_hfm, {[5,5,1.2,10,0],[5,5,1.4,15,0]}, [1,1,1,1,1], {{{1,1,0},{2,2,0}}}, 'evaluate' );

% Fit
[wfit_ref,fitpar_ref]=multifit_sqw_sqw(win, @sqw_bcc_hfm, [5,5,0,10,0], [1,1,0,0,0],...
    @sqw_bcc_hfm, {[5,5,1.2,10,0],[5,5,1.4,15,0]}, [1,1,1,1,1], {{{1,1,0},{2,2,0}}});


acolor r b
dp(win)
pl(wfit_ref)



% New multifit
% -----------------
% Simulate
kk = multifit2_sqw (win);
kk = kk.set_local_foreground;
kk = kk.set_fun (@sqw_bcc_hfm, {[5,5,1.2,10,0],[5,5,1.4,15,0]});
kk = kk.set_bind ({1,[1,1]},{2,[2,1]});

[wcalc,calcdata,ok,mess] = kk.simulate;
if~isequaln(wcalc_ref,wcalc), error('*** Oh dear! ***'), end

[wfit,fitdata,ok,mess] = kk.fit;
if~isequaln(wfit_ref,wfit), error('*** Oh dear! ***'), end


%% ------------------------------------------------------------------------------------------------
% average
% -----------

% This will be faster, because it gets the average h,k,l,e for all data pixels in a bin
% and evaluates only at that point. The final answer will be a little different of course -
% the extent will be dependent on how rapidly your dispersion function varies, and how big your
% bins are in the cut.
[wcalc_ave_ref,calcpar_ave_ref]=multifit_sqw_sqw(win, @sqw_bcc_hfm, [5,5,0,10,0], [1,1,0,0,0],...
    @sqw_bcc_hfm, {[5,5,1.2,10,0],[5,5,1.4,15,0]}, [1,1,1,1,1], {{{1,1,0},{2,2,0}}}, 'evaluate', 'ave' );
    
[wfit_ave_ref,fitpar_ave_ref]=multifit_sqw_sqw(win, @sqw_bcc_hfm, [5,5,0,10,0], [1,1,0,0,0],...
    @sqw_bcc_hfm, {[5,5,1.2,10,0],[5,5,1.4,15,0]}, [1,1,1,1,1], {{{1,1,0},{2,2,0}}}, 'ave' );




% New multifit
% -----------------
% Simulate
kk = multifit2_sqw (win);
kk = kk.set_local_foreground;
kk = kk.set_fun (@sqw_bcc_hfm, {[5,5,1.2,10,0],[5,5,1.4,15,0]});
kk = kk.set_bind ({1,[1,1]},{2,[2,1]});
kk.average = true;

[wcalc_ave,calcdata_ave,ok,mess] = kk.simulate;
if~isequaln(wcalc_ave_ref,wcalc_ave), error('*** Oh dear! ***'), end

[wfit_ave,fitdata_ave,ok,mess] = kk.fit;
if~isequaln(wfit_ave_ref,wfit_ave), error('*** Oh dear! ***'), end


acolor r b
dp(win)
pl(wfit_ave_ref)




