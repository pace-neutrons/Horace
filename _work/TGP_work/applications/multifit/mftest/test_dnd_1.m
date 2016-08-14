% ------------------------------------------------------------------------------------------------
% Example of fitting more than one sqw object
% -------------------------------------------------------------------------------------------------

% Read in data
% ------------
w1data=read_sqw(fullfile('./data/w1data.sqw'));
w2data=read_sqw(fullfile('./data/w2data.sqw'));


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

din=dnd([w1data,w2data]);

% Fudge the energy
din(1).iint(:,3)=[12,18]';
din(2).iint(:,3)=[20,30]';


% Original multifit
% -----------------
% Simulate
[dcalc_ref,calcpar_ref]=multifit_sqw_sqw(din, @sqw_bcc_hfm, [5,5,0,10,0], [1,1,0,0,0],...
    @sqw_bcc_hfm, {[5,5,1.2,10,0],[5,5,1.4,15,0]}, [1,1,1,1,1], {{{1,1,0},{2,2,0}}}, 'evaluate' );

% Fit
[dfit_ref,fitpar_ref]=multifit_sqw_sqw(din, @sqw_bcc_hfm, [5,5,0,10,0], [1,1,0,0,0],...
    @sqw_bcc_hfm, {[5,5,1.2,10,0],[5,5,1.4,15,0]}, [1,1,1,1,1], {{{1,1,0},{2,2,0}}});


acolor r b
dp(din)
pl(dfit_ref)



% New multifit
% -----------------
% Simulate
kk = multifit2_sqw (din);
kk = kk.set_local_foreground;
kk = kk.set_fun (@sqw_bcc_hfm, {[5,5,1.2,10,0],[5,5,1.4,15,0]});
kk = kk.set_bind ({1,[1,1]},{2,[2,1]});

[dcalc,calcdata,ok,mess] = kk.simulate;
if~isequaln(dcalc_ref,dcalc), error('*** Oh dear! ***'), end

[dfit,fitdata,ok,mess] = kk.fit;
if~isequaln(dfit_ref,dfit), error('*** Oh dear! ***'), end





