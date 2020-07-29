function test_tobyfit_1 (option, version)
% Test basic aspects of Tobyfit
%
% Perform tests:
%   >> test_tobyfit_1               % Run the Tobyfit tests and test against stored fit
%                                   % parameters in test_tobyfit_1_out.mat in the same
%                                   % folder as this file
%
%   >> test_tobyfit_1 ('-save')     % Run the Tobyfit tests and save fit parameters
%                                   % to file test_tobyfit_1_out.mat
%                                   % in the temporary folder (given by tmp_dir)
%                                   % Copy to the same folder as this file to use in
%                                   % tests.
%
%   >> test_tobyfit_1 ('-notest')   % Run without testing against previously stored results.
%                                   % For performing visual checks or debugging the tests!

% ----------------------------------------------------------------------------
% Setup (should only have to do in extremis - assumes data on Toby Perring's computer
%   >> test_tobyfit_1 ('-setup')    % Create the cuts that will be fitted and save in
%                                   % test_tobyfit_1_data.mat in the temporary folder
%                                   % given by tmp_dir. Copy this file to the same folder
%                                   % that holds this .m file to use it in the following
%                                   % tests
%   >> status = test_tobyfit_1 ('-setup')


%% --------------------------------------------------------------------------------------
nlist = 0;  % set to 1 or 2 for listing during fit

% Determine whether or not to save output
save_data = false;
save_output = false;
test_output = true;

if exist('option','var')
    if ischar(option) && isequal(lower(option),'-setup')
        save_data = true;
        test_output = false;
    elseif ischar(option) && isequal(lower(option),'-save')
        save_output = true;
        test_output = false;
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

%% --------------------------------------------------------------------------------------
% Setup
%data_source='E:\data\aaa_Horace\Fe_ei787.sqw';  % sqw file from which to take cuts for setup
data_source='D:\data\Fe\sqw_Toby\Fe_ei787.sqw';  % sqw file from which to take cuts for setup

datafile='test_tobyfit_1_data.mat';   % filename where saved results are written
savefile='test_tobyfit_1_out.mat';   % filename where saved results are written

% This seed provides a passing test at time of writing
fixed_seed = 0;
[old_rng_state, rng_state] = seed_rng(fixed_seed);
clean_up = onCleanup(@() rng(old_rng_state));
fprintf('RNG seed: %i\n', rng_state.Seed);

%% --------------------------------------------------------------------------------------
% Create cuts to save as input data
% --------------------------------------------------------------------------------------
if save_data
    % Short cut along [1,1,0]
    proj.u=[1,1,0];
    proj.v=[-1,1,0];
    w110a=cut_sqw(data_source,proj,[0.95,1.05],[-0.6,0.05,0.6],[-0.05,0.05],[150,160]);
    
    % Long cut along [1,1,0]
    proj.u=[1,1,0];
    proj.v=[-1,1,0];
    w110b=cut_sqw(data_source,proj,[0.95,1.05],[-2,0.05,3],[-0.05,0.05],[150,160]);
    
    % Create cuts to simulate or fit simultaneously
    proj.u=[1,1,0];
    proj.v=[-1,1,0];
    w110_1=cut_sqw(data_source,proj,[0.95,1.05],[-0.6,0.05,0.6],[-0.05,0.05],[140,160]);
    w110_2=cut_sqw(data_source,proj,[0.95,1.05],[-0.6,0.05,0.6],[-0.05,0.05],[160,180]);
    w110_3=cut_sqw(data_source,proj,[0.95,1.05],[-0.6,0.05,0.6],[-0.05,0.05],[180,200]);
    
    w110arr=[w110_1,w110_2,w110_3];
    
    % Now save to file for future use
    datafile_full = fullfile(tmp_dir,datafile);
    save(datafile_full,'w110a','w110b','w110arr');
    disp(['Saved data for future use in',datafile_full])
    return
    
else
    % Read in data
    load(datafile);
end

% Add instrumnet and sample information to cuts
sample=IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.04,0.03,0.02]);
w110a=set_sample_and_inst(w110a,sample,@maps_instrument_obj_for_tests,'-efix',600,'S');
w110b=set_sample_and_inst(w110b,sample,@maps_instrument_obj_for_tests,'-efix',600,'S');
w110arr(1) = set_sample_and_inst(w110arr(1),sample,@maps_instrument_obj_for_tests,'-efix',600,'S');
w110arr(2) = set_sample_and_inst(w110arr(2),sample,@maps_instrument_obj_for_tests,'-efix',600,'S');
w110arr(3) = set_sample_and_inst(w110arr(3),sample,@maps_instrument_obj_for_tests,'-efix',600,'S');


%% --------------------------------------------------------------------------------------
% Read test results if necessary
% --------------------------------------------------------------------------------------
if test_output
    tmp=load(savefile);
    fac=[0.25,1,0.1];    % used by comparison function
end


%% --------------------------------------------------------------------------------------
% Evaluate sqw and Tobyfit simulation for single cut
% --------------------------------------------------------------------------------------
% Visually check that the simulations are OK: the non-Tobyfit peaks will be
% sharper than the data, the Tobyfit simulations similar to the data

% ---------------------------------------------------------------------------------------
% Short cut
amp=1;  sj=40;   fwhh=50;

% Evaluate S(Q,w) model
w110a_eval=sqw_eval(w110a,@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
acolor k; dd(w110a_eval)
pause(1)

% Tobyfit simulation
kk=tobyfit(w110a);
kk=kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
kk=kk.set_mc_points(10);
w110a_sim=kk.simulate;

acolor b; pd(w110a_sim)
pause(2)

% ---------------------------------------------------------------------------------------
% Long cut
amp=1;  sj=40;   fwhh=50;

% Evaluate S(Q,w) model
w110b_eval=sqw_eval(w110b,@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
acolor k; dd(w110b_eval)
pause(1)

% Tobyfit simulation
kk=tobyfit(w110b);
kk=kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
kk=kk.set_mc_points(10);
w110b_sim=kk.simulate;

acolor b; pd(w110b_sim)

pause(2)


%% --------------------------------------------------------------------------------------
% Fit single cuts
% --------------------------------------------------------------------------------------

% ---------------------------------------------------------------------------------------
% An example of having starting parameters close to a good fit

amp=50;  sj=40;   fwhh=50;   const=0.1;  grad=0;

kk = tobyfit(w110a);
kk = kk.set_fun(@testfunc_sqw_bcc_hfm_bkgd,[amp,sj,fwhh,const,grad]);
kk = kk.set_mc_points(10);
w110a1_sim=kk.simulate;

acolor b; dd(w110a); acolor k; pl(w110a1_sim); ly 0 0.4
pause(1)

kk = tobyfit(w110a);
kk = kk.set_fun(@testfunc_sqw_bcc_hfm_bkgd,[amp,sj,fwhh,const,grad],[1,0,0,1,0]);
kk = kk.set_mc_points(10);
kk = kk.set_options('listing',nlist);
[w110a1_tf,fp110a1]=kk.fit;

acolor r; pl(w110a1_tf); ly 0 0.4
pause(2)

if test_output
    disp('Comparing with stored fit')
    if ~is_same_fit (fp110a1,   tmp.fp110a1,   fac, [1,0,0,0,0])
        error('fp110a1 not same')
    end
end

% ---------------------------------------------------------------------------------------
% From a poor starting position
amp=100;  sj=40;   fwhh=50;   const=0;  grad=0;

kk = tobyfit(w110a);
kk = kk.set_fun(@testfunc_sqw_bcc_hfm_bkgd,[amp,sj,fwhh,const,grad]);
kk = kk.set_mc_points(10);
w110a2_sim=kk.simulate;

acolor b; dd(w110a); acolor k; pl(w110a2_sim); ly 0 0.4
pause(1)

kk = tobyfit(w110a);
kk = kk.set_fun(@testfunc_sqw_bcc_hfm_bkgd,[amp,sj,fwhh,const,grad],[1,0,0,1,0]);
kk = kk.set_mc_points(10);
kk = kk.set_options('listing',nlist);
[w110a2_tf,fp110a2]=kk.fit;

acolor r; pl(w110a2_tf); ly 0 0.4
pause(2)

if test_output
    disp('Comparing with stored fit')
    if ~is_same_fit (fp110a2,   tmp.fp110a2,   fac, [1,0,0,0,0])
        error('fp110a2 not same')
    end
end

% ---------------------------------------------------------------------------------------
% Decouple foreground and background - get same result, so good!
amp=100;  sj=40;   fwhh=50;   const=0;  grad=0;

kk = tobyfit(w110a);
kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh,const,grad]);
kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
kk = kk.set_mc_points(10);
w110a3_sim=kk.simulate;

acolor b; dd(w110a); acolor k; pl(w110a3_sim); ly 0 0.4
pause(1)

kk = tobyfit(w110a);
kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
kk = kk.set_free([1,0,0]);
kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
kk = kk.set_bfree([1,0]);
kk = kk.set_mc_points(10);
kk = kk.set_options('listing',nlist);
[w110a3_tf,fp110a3]=kk.fit;

acolor r; pl(w110a3_tf); ly 0 0.4
pause(2)

if test_output
    disp('Comparing with stored fit')
    if ~is_same_fit (fp110a3,   tmp.fp110a3,   fac, [1,0,0], [0,0])
        error('fp110a3 not same')
    end
end

% ---------------------------------------------------------------------------------------
% Allow all parameters to vary
amp=100;  sj=40;   fwhh=50;   const=0;  grad=0;

kk = tobyfit(w110a);
kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh,const,grad]);
kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
kk = kk.set_mc_points(10);
w110a4_sim=kk.simulate;

acolor b; dd(w110a); acolor k; pl(w110a4_sim); ly 0 0.4
pause(1)

kk = tobyfit(w110a);
kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
kk = kk.set_mc_points(10);
kk = kk.set_options('listing',nlist);
[w110a4_tf,fp110a4]=kk.fit;

acolor r; pl(w110a4_tf); ly 0 0.4
pause(2)

if test_output
    disp('Comparing with stored fit')
    if ~is_same_fit (fp110a4,   tmp.fp110a4,   fac)
        error('fp110a4 not same')
    end
end

%% --------------------------------------------------------------------------------------
% Fit multiple datasets
% ---------------------------------------------------------------------------------------

% ---------------------------------------------------------------------------------------
% Global foreground; allow all parameters to vary
amp=100;  sj=40;   fwhh=50;   const=0;  grad=0;


kk = tobyfit(w110arr);
kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
kk = kk.set_mc_points(10);
w110arr1_sim=kk.simulate;

acolor k b r; dp(w110arr); pl(w110arr1_sim); ly 0 0.8
pause(1)

kk = tobyfit(w110arr);
kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
kk = kk.set_mc_points(10);
kk = kk.set_options('listing',nlist);
[w110arr1_tf,fp110arr1]=kk.fit;

fback = kk.simulate(fp110arr1,'back');
pl(fback)

acolor k b r; pl(w110arr1_tf); ly 0 0.4
pause(2)

if test_output
    disp('Comparing with stored fit')
    if ~is_same_fit (fp110arr1,   tmp.fp110arr1,   fac)
        error('fp110arr1 not same')
    end
end

% ---------------------------------------------------------------------------------------
% Local foreground; constrain SJ as global but allow amplitude and gamma to vary locally
amp=100;  sj=40;   fwhh=50;   const=0;  grad=0;

kk = tobyfit(w110arr);
kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
kk = kk.set_mc_points(10);
w110arr2_sim=kk.simulate;

acolor k b r; dp(w110arr); pl(w110arr2_sim); ly 0 0.8
pause(1)

kk = tobyfit(w110arr);
kk = kk.set_local_foreground;
kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
kk = kk.set_bind({2,[2,1]});
kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
kk = kk.set_mc_points(10);
kk = kk.set_options('listing',nlist);
[w110arr2_tf,fp110arr2]=kk.fit;

acolor k b r; pl(w110arr2_tf); ly 0 0.4
fback = kk.simulate(fp110arr2,'back');
pl(fback)

pause(2)

if test_output
    disp('Comparing with stored fit')
    if ~is_same_fit (fp110arr2,   tmp.fp110arr2,   fac)
        error('fp110arr2 not same')
    end
end

% %% --------------------------------------------------------------------------------------
% % Collect results together as a structure
% % ---------------------------------------------------------------------------------------
% 
% % Cuts
% res.w110a=w110a;
% res.w110b=w110b;
% res.w110arr=w110arr;
% 
% % First simulations
% res.w110a_eval=w110a_eval;
% res.w110a_sim=w110a_sim;
% 
% res.w110b_eval=w110b_eval;
% res.w110b_sim=w110b_sim;
% 
% % Fits to single cuts
% res.w110a1_sim=w110a1_sim;
% res.w110a1_tf=w110a1_tf;
% res.fp110a1=fp110a1;
% 
% res.w110a2_sim=w110a2_sim;
% res.w110a2_tf=w110a2_tf;
% res.fp110a2=fp110a2;
% 
% res.w110a3_sim=w110a3_sim;
% res.w110a3_tf=w110a3_tf;
% res.fp110a3=fp110a3;
% 
% res.w110a4_sim=w110a4_sim;
% res.w110a4_tf=w110a4_tf;
% res.fp110a4=fp110a4;
% 
% % Fits to multiple cuts
% res.w110arr1_sim=w110arr1_sim;
% res.w110arr1_tf=w110arr1_tf;
% res.fp110arr1=fp110arr1;
% 
% res.w110arr2_sim=w110arr2_sim;
% res.w110arr2_tf=w110arr2_tf;
% res.fp110arr2=fp110arr2;



%% --------------------------------------------------------------------------------------
% Save fit parameter output if requested
% ---------------------------------------------------------------------------------------
if save_output
    save(fullfile(tmp_dir,savefile),...
        'fp110a1','fp110a2','fp110a3','fp110a4','fp110arr1','fp110arr2');
end


