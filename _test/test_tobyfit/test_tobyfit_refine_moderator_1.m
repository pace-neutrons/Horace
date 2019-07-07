function varargout = test_tobyfit_refine_moderator_1 (option, version)
% Test Tobyfit versions refining moderator parameter for a single sqw dataset
%
% Perform tests:
%   >> test_tobyfit_refine_moderator_1  % Run the Tobyfit tests and test against stored fit
%                                       % parameters in test_tobyfit_refine_moderator_1_out.mat
%                                       % in the same folder as this file
%
%   >> test_tobyfit_refine_moderator_1 ('-save')% Run the Tobyfit tests and save fit parameters
%                                               % to file test_tobyfit_refine_moderator_1_out.mat
%                                               % in the temporary folder (given by tempdir)
%                                               % Copy to the same folder as this file to use in
%                                               % tests.
%
%   >> test_tobyfit_refine_moderator_1 ('-notest')  % Run without testing against previously stored results.
%                                                   % For performing visual checks or debugging the tests!
%
%
% Do any of the above, run with the legacy version of Tobyfit:
%   >> test_tobyfit_1 (...,'-legacy')
%
% In all of the above, get the full output of the fits as a structure:
%
%   >> res = test_tobyfit_refine_moderator_1 (...)

% ----------------------------------------------------------------------------
% Setup (should only have to do in extremis - assumes data on Toby Perring's computer
%   >> test_tobyfit_refine_moderator_1 ('-setup')
%                                   % Create the cuts that will be fitted and save in
%                                   % test_tobyfit_refine_moderator_1.mat in the temporary
%                                   % folder given by tempdir. Copy this file to the same folder
%                                   % that holds this .m file to use it in the following
%                                   % tests
%
%   >> status = test_tobyfit_refine_moderator_1 ('-setup')


%% --------------------------------------------------------------------------------------
nlist = 1;  % set to 1 or 2 for listing during fit

% Determine whether or not to save output
save_data = false;
save_output = false;
test_output = true;
legacy = false;

if exist('option','var')
    if ischar(option) && isequal(lower(option),'-setup')
        save_data = true;
    elseif ischar(option) && isequal(lower(option),'-save')
        save_output = true;
    elseif ischar(option) && isequal(lower(option),'-notest')
        test_output = false;
    else
        if ~exist('version','var')
            version = option;
        else
            error('Invalid option')
        end
    end
end

if exist('version','var')
    if ischar(version) && isequal(lower(version),'-legacy')
        legacy = true;
    else
        error('Invalid option(s)')
    end
end

if legacy
    disp('Legacy Tobyfit...')
end


%% ================================================================================================
% Setup
% -----
data_source='E:\data\aaa_Horace\rbmnf3_backup_v1.sqw';  % sqw file from which to take cuts for setup

datafile='test_tobyfit_refine_moderator_1_data.mat';   % filename where saved results are written
savefile='test_tobyfit_refine_moderator_1_out.mat';   % filename where saved results are written


%% ================================================================================================
% Create cuts to save as input data
% --------------------------------------------------------------------------------------

if save_data
    proj.u=[1,1,0];
    proj.v=[0,0,1];
    w1inc=cut_sqw(data_source,proj,[0.3,0.5],[0,0.2],[-0.1,0.1],[-3,0.1,3]);
    
    % Now save to file for future use
    datafile_full = fullfile(tempdir,datafile);
    save(datafile_full,'w1inc');
    disp(['Saved data for future use in',datafile_full])
    if nargout>0
        varargout{1}=true;
    end
    return
    
else
    % Read in data
    load(datafile);
end

% Add instrumnet and sample information to cuts
sample=IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.02,0.02,0.02]);
w1inc=set_sample(w1inc,sample);
w1inc=set_instrument(w1inc,@maps_instrument_obj_for_tests,'-efix',300,'S');


%% ================================================================================================
% Read test results if necessary
% --------------------------------------------------------------------------------------
if test_output
    tmp=load(savefile);
    fac=1;  %used by comparison function
end


%% ================================================================================================
% Tobyfit
% ----------------------------------------

% Get moderator pulse name and parameters
[pulse_model,ppmod,ok]=get_mod_pulse(w1inc);
if ~ok, error(mess), end    % check name and parameters are all the same (within some small tolerance)

% Set moderator tauf to something else to actually test fitting
ppmod=0.65*ppmod;
w1inc = set_mod_pulse(w1inc,pulse_model,ppmod);

% Tobyfitting proper
% ------------------
mc=2;
if legacy
    % We can see that the model is 'ikcarp' and it has three parameters; we are only going to refine the first one
    mod_opts=tobyfit_refine_moderator_options([1,0,0]);   % take default moderator parameters as starting point
    
    % Could equally well have set the options explicity from the previously extracted values, or
    % a different model altogether
    mod_opts=tobyfit_refine_moderator_options(pulse_model,ppmod,[1,0,0]);
    
    % Check we have good starting parameters
    amp=100;  en0=0;   fwhh=0.25;
    wtmp=tobyfit(w1inc,@testfunc_sqw_van,[amp,en0,fwhh],[1,1,0],'mc_npoints',mc,'refine_mod',mod_opts,'eval');
    acolor b; dd(w1inc); acolor k; pl(wtmp)
    
    % Good choice of parameters, so start the fit
    [w1fit,pfit,ok,mess,pmodel,ppfit]=tobyfit(w1inc,@testfunc_sqw_van,[amp,en0,fwhh],[1,1,0],'mc_npoints',mc,'refine_mod',mod_opts,'list',nlist);
    acolor r; pl(w1fit)
    
    % Happy with the fit (ppfit(1)=10.35 +/- 0.28)
    
else
    % Equivalent with new tobyfit
    
    kk = tobyfit (w1inc);
    kk = kk.set_refine_moderator (pulse_model,ppmod,[1,0,0]);
    kk = kk.set_mc_points (mc);
    
    amp=100;  en0=0;   fwhh=0.25;
    kk = kk.set_fun (@testfunc_sqw_van, [amp,en0,fwhh], [1,1,0]);
    
    % Simulate
    wtmp = kk.simulate;
    acolor b; dd(w1inc); acolor k; pl(wtmp)
    
    % Fit
    kk = kk.set_options('list',nlist);
    [w1fit,pfit,ok,mess,pmodel,ppfit,psigfit] = kk.fit;
    acolor r; pl(w1fit)
    
end

if test_output
    disp('Comparing with stored fit')
    if ~is_same_fit (pfit,   tmp.pfit,   fac, [1,0,1,1,1,1])  % dont compare shift, as so small
        warning('fit parameters not same as those stored. Press <cr> to continue')
        pause
        error('fit parameters not same as those stored')
    end
end


%% ================================================================================================
% Collect results together as a structure
% ---------------------------------------------------------------------------------------
res.w1fit=w1fit;
res.pfit=pfit;
res.pmodel=pmodel;
res.ppfit=ppfit;

if nargout>0
    varargout{1}=res;
end


%% ================================================================================================
% Save fit parameter output if requested
% ---------------------------------------------------------------------------------------
if save_output
    save(fullfile(tempdir,savefile),'pfit','ppfit');
end

