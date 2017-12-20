function test_sqw_2
% Test of timing of multifit2 with sqw objects

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


% Make a big set of sqw objects
nrep=50;
win=[noisify(repmat(w1data,1,nrep),0.03),noisify(repmat(w2data,1,nrep),0.03)];

% Ensure fit control parameters are the same for old and new multifit
fcp = [0.0001 30 0.0001];

disp('Timing test:')

% Original multifit
% -----------------
pin1 = [5,5,1.2,10,0];
pin2 = [5,5,1.4,15,0];
pin = [repmat({pin1},1,nrep),repmat({pin2},1,nrep)];

% *** Profile this line ***
timer = bigtic;
[wfit_ref,fitpar_ref]=multifit_sqw_sqw(win,...
    @sqw_bcc_hfm, [5,5,0,10,0], [1,1,0,0,0],...
    @sqw_bcc_hfm, pin, [1,1,1,1,1], {{{1,1,0},{2,2,0}}},...
    'fitcontrolparameters',fcp);
t_old = bigtoc(timer);
disp(['  Multifit: wall time: ',num2str(t_old(1)),'   CPU time: ',num2str(t_old(2))])



% New multifit
% -----------------
% Simulate
kk = multifit2_sqw (win);
kk = kk.set_local_foreground;
kk = kk.set_fun (@sqw_bcc_hfm, pin);
kk = kk.set_bind ({1,[1,1]},{2,[2,1]});
kk = kk.set_options('fit_control_parameters',fcp);

timer = bigtic;
[wfit,fitdata,ok,mess] = kk.fit;
t_new = bigtoc(timer);
disp([' Multifit2: wall time: ',num2str(t_new(1)),'   CPU time: ',num2str(t_new(2))])

if~isequaln(wfit_ref,wfit), error('*** Oh dear! ***'), end

