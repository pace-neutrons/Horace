function test_tobyfit_let_1 (option)
% Test basic aspects of Tobyfit
%
% Perform tests:
%   >> test_tobyfit_let_1           % Run the Tobyfit tests and test against stored fit
%                                   % parameters in test_tobyfit_let_1_out.mat in the same
%                                   % folder as this file
%
%   >> test_tobyfit_let_1 ('-save') % Run the Tobyfit tests and save fit parameters
%                                   % to file test_tobyfit_let_1_out.mat
%                                   % in the temporary folder (given by tempdir)
%                                   % Copy to the same folder as this file to use in
%                                   % tests.
%
%   >> test_tobyfit_let_1 ('-notest')   % Run without testing against previously stored results.
%                                       % For performing visual checks or debugging the tests!


%% --------------------------------------------------------------------------------------
nlist = 0;  % set to 1 or 2 for listing during fit

% Determine whether or not to save output
save_output = false;
test_output = true;

if exist('option','var')
    if ischar(option) && isequal(lower(option),'-save')
        save_output = true;
    elseif ischar(option) && isequal(lower(option),'-notest')
        test_output = false;
    else
        error('Invalid option')
    end
end


%% --------------------------------------------------------------------------------------
% Setup
datafile='test_tobyfit_let_1_data.mat';   % filename where saved results are written
savefile='test_tobyfit_let_1_out.mat';   % filename where saved results are written


%% --------------------------------------------------------------------------------------
% Read cuts
% --------------------------------------------------------------------------------------

% Read in data
load(datafile);

efix = 8.04;
instru = let_instrument_obj_for_tests (efix, 280, 140, 20, 2, 2);
sample = IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.012,0.012,0.04]);

w1a = set_instrument (w1a, instru);
w1a = set_sample (w1a, sample);

w1b = set_instrument (w1b, instru);
w1b = set_sample (w1b, sample);

wdata_1 = [w1a,w1b];


%% --------------------------------------------------------------------------------------
% Read test results if necessary
% --------------------------------------------------------------------------------------
if test_output
    tmp=load(savefile);
end


%% --------------------------------------------------------------------------------------
% Fit multiple datasets for Nb
% ---------------------------------------------------------------------------------------
% Local foreground; constrain gamma as global but allow amplitude to vary locally
amp=6000;    fwhh=0.2;

disp(' ')
disp('Fitting Nb data...')
kk = tobyfit(wdata_1);
kk = kk.set_local_foreground;
kk = kk.set_fun(@testfunc_nb_sqw,[amp,fwhh]);
kk = kk.set_bind({2,[2,1]});
kk = kk.set_bfun(@testfunc_bkgd,[0,0]);
kk = kk.set_mc_points(2);
kk = kk.set_options('listing',nlist);

[wfit_1,fitpar_1]=kk.fit;

acolor r b; plot(wdata_1); pl(wfit_1);


if test_output
    disp('Comparing with stored fit')
    fac=[0.5,0,0.02,0.02];
    if ~is_same_fit (fitpar_1,   tmp.fitpar_1,   fac)
        error('par_fe_tf_1 not same')
    end
end



% %% --------------------------------------------------------------------------------------
% % Collect results together as a structure
% % ---------------------------------------------------------------------------------------
% 
% % Cuts
% res.wdata_1 = wdata_1;
% res.wfit_1 = wfit_1;
% res.fitpar_1 = fitpar_1;



%% --------------------------------------------------------------------------------------
% Save fit parameter output if requested
% ---------------------------------------------------------------------------------------
if save_output
    % Strip away the instrument and sample info (we keep the sqw files clean)
    wdata_1 = set_instrument(wdata_1,struct());
    wdata_1 = set_sample(wdata_1,struct());
    wfit_1 = set_instrument(wfit_1,struct());
    wfit_1 = set_sample(wfit_1,struct());
    save(fullfile(tempdir,savefile),...
        'wdata_1','wfit_1','fitpar_1');
end
