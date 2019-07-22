function test_tobyfit_2 (option)
% Test basic aspects of Tobyfit
%
% Perform tests:
%   >> test_tobyfit_2               % Run the Tobyfit tests and test against stored fit
%                                   % parameters in test_tobyfit_2_out.mat in the same
%                                   % folder as this file
%
%   >> test_tobyfit_2 ('-save')     % Run the Tobyfit tests and save fit parameters
%                                   % to file test_tobyfit_2_out.mat
%                                   % in the temporary folder (given by tempdir)
%                                   % Copy to the same folder as this file to use in
%                                   % tests.
%
%   >> test_tobyfit_2 ('-notest')   % Run without testing against previously stored results.
%                                   % For performing visual checks or debugging the tests!


% ----------------------------------------------------------------------------
% Setup (should only have to do in extremis - assumes data on Toby Perring's computer
%   >> test_tobyfit_2 ('-setup')    % Create the cuts that will be fitted and save in
%                                   % test_tobyfit_2_data.mat in the temporary folder
%                                   % given by tempdir. Copy this file to the same folder
%                                   % that holds this .m file to use it in the following
%                                   % tests
%   >> status = test_tobyfit_2 ('-setup')
%

%% --------------------------------------------------------------------------------------
nlist = 0;  % set to 1 or 2 for listing during fit

% Determine whether or not to save output
save_data = false;
save_output = false;
test_output = true;

if exist('option','var')
    if ischar(option) && isequal(lower(option),'-setup')
        save_data = true;
    elseif ischar(option) && isequal(lower(option),'-save')
        save_output = true;
    elseif ischar(option) && isequal(lower(option),'-notest')
        test_output = false;
    else
        error('Invalid option')
    end
end


%% --------------------------------------------------------------------------------------
% Setup
data_source_fe='D:\data\Fe\sqw_Toby\Fe_ei787.sqw';  % sqw file from which to take cuts for setup
data_source_rb = 'T:\data\RbMnF3\sqw\rbmnf3_ref_newformat.sqw';

datafile='test_tobyfit_2_data.mat';     % filename where saved data are written
savefile='test_tobyfit_2_out.mat';      % filename where saved results are written



%% --------------------------------------------------------------------------------------
% Create cuts to save as input data
% --------------------------------------------------------------------------------------
if save_data
    % Cuts from iron
    % --------------
    proj_fe = projaxes([1,1,0],[-1,1,0]);
    
    % Short cut along [1,1,0]
    fe_1=cut_sqw(data_source_fe,proj_fe,[0.95,1.05],[-0.6,0.05,0.6],[-0.05,0.05],[150,160]);
    
    % Long cut along [1,1,0]
    fe_2=cut_sqw(data_source_fe,proj_fe,[0.95,1.05],[-2,0.05,3],[-0.05,0.05],[150,160]);
    
    % Create cuts to simulate or fit simultaneously
    tmp_1=cut_sqw(data_source_fe,proj_fe,[0.95,1.05],[-0.6,0.05,0.6],[-0.05,0.05],[140,160]);
    tmp_2=cut_sqw(data_source_fe,proj_fe,[0.95,1.05],[-0.6,0.05,0.6],[-0.05,0.05],[160,180]);
    tmp_3=cut_sqw(data_source_fe,proj_fe,[0.95,1.05],[-0.6,0.05,0.6],[-0.05,0.05],[180,200]);
    
    fe_arr=[tmp_1,tmp_2,tmp_3];
    
    % Cuts from RbMnF3
    % ----------------
    proj_rb = projaxes([1,1,0],[0,0,1]);
    rb_1 = cut_sqw(data_source_rb,proj_rb,[0.45,0.55],[-0.05,0.05],[-0.05,0.05],[5,0,11]);
    
    tmp_1 = cut_sqw(data_source_rb,proj_rb,[0.45,0.55],[0.25,0.35],[-0.05,0.05],[2,0,10]);
    tmp_2 = cut_sqw(data_source_rb,proj_rb,[0.45,0.55],[0.15,0.25],[-0.05,0.05],[2,0,10]);
    
    rb_arr = [tmp_1;tmp_2];
    
    
    % Now save to file for future use
    datafile_full = fullfile(tempdir,datafile);
    save(datafile_full,'fe_1','fe_2','fe_arr','rb_1','rb_arr');
    disp(['Saved data for future use in',datafile_full])
    return
    
else
    % Read in data
    load(datafile);
end

% Add instrument and sample information to cuts
sample_fe=IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.03,0.03,0.04]);
fe_1=set_sample_and_inst(fe_1,sample_fe,@maps_instrument_obj_for_tests,'-efix',600,'S');
fe_2=set_sample_and_inst(fe_2,sample_fe,@maps_instrument_obj_for_tests,'-efix',600,'S');
for i=1:numel(fe_arr)
    fe_arr(i)=set_sample_and_inst(fe_arr(i),sample_fe,@maps_instrument_obj_for_tests,'-efix',600,'S');
end

sample_rb=IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.02,0.02,0.02]);
rb_1=set_sample_and_inst(rb_1,sample_rb,@maps_instrument_obj_for_tests,'-efix',300,'S');
for i=1:numel(rb_arr)
    rb_arr(i)=set_sample_and_inst(rb_arr(i),sample_rb,@maps_instrument_obj_for_tests,'-efix',300,'S');
end

fe = [fe_1,fe_2,fe_arr];
rb = [rb_1;rb_arr];
ferb = [fe_1,fe_2,rb_1,fe_arr,rb_arr'];

%% --------------------------------------------------------------------------------------
% Read test results if necessary
% --------------------------------------------------------------------------------------
if test_output
    tmp=load(savefile);
    fac=[0.25,1,0.1];    % used by comparison function
end


%% --------------------------------------------------------------------------------------
% Fit multiple datasets for Fe
% ---------------------------------------------------------------------------------------
% Local foreground; constrain SJ as global but allow amplitude and gamma to vary locally
amp=100;  sj=40;   fwhh=50;   const=0;  grad=0;

disp(' ')
disp('Fitting Fe data...')
kk = tobyfit(fe);
kk = kk.set_local_foreground;
kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
kk = kk.set_bind({2,[2,1]});
kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
kk = kk.set_mc_points(10);
kk = kk.set_options('listing',nlist);
[fe_tf_1,par_fe_tf_1]=kk.fit;

fback = kk.simulate(par_fe_tf_1,'back');
acolor k b r m g; dm(fe); pl(fe_tf_1); lx -1 1; ly 0 0.4
pl(fback)


if test_output
    disp('Comparing with stored fit')
    if ~is_same_fit (par_fe_tf_1,   tmp.par_fe_tf_1,   fac)
        error('par_fe_tf_1 not same')
    end
end



%% --------------------------------------------------------------------------------------
% Fit multiple datasets for Rb
% ---------------------------------------------------------------------------------------
% Local foreground; constrain SJ as global but allow amplitude and gamma to vary locally
Seff = 6000; SJ = 8.8; gap = 0.01; gam=0.04;   const=0;  grad=0;

disp(' ')
disp('Fitting RbMnF3 data...')
kk = tobyfit(rb);
kk = kk.set_local_foreground;
kk = kk.set_fun(@testfunc_rbmnf3_sqw,[Seff, SJ, gap, gam],[1,1,0,0]);
kk = kk.set_bind({2,[2,1]});
kk = kk.set_bfun(@testfunc_bkgd,[const,grad],[1,0]);
kk = kk.set_mc_points(10);
kk = kk.set_options('listing',nlist);
[rb_tf_1,par_rb_tf_1]=kk.fit;

fback = kk.simulate(par_rb_tf_1,'back');
acolor k b r m g; dm(rb); pl(rb_tf_1); ly 0 500
pl(fback)


if test_output
    disp('Comparing with stored fit')
    if ~is_same_fit (par_rb_tf_1,   tmp.par_rb_tf_1,   fac)
        error('par_rb_tf_1 not same')
    end
end


%% --------------------------------------------------------------------------------------
% Fit multiple datasets for Fe and Rb simultaneously
% ---------------------------------------------------------------------------------------
% Same fit as above, except constrain the ratio of the exchange constants to enforce
% a coupling

amp=100;  sj=40;   fwhh=50;
Seff = 6000; SJ = 8.8; gap = 0.01; gam=0.04;
const=0;  grad=0;

disp(' ')
disp('Fitting Fe and RbMnF3 data together...')
kk = tobyfit(ferb);
fe_datasets = [1,2,4,5,6];
rb_datasets = [3,7,8];
kk = kk.set_local_foreground;
kk = kk.set_fun(fe_datasets,@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
kk = kk.set_bind(fe_datasets,{2,[2,1]});
kk = kk.set_bfun(fe_datasets,@testfunc_bkgd,[const,grad]);
kk = kk.set_fun(rb_datasets,@testfunc_rbmnf3_sqw,[Seff, SJ, gap, gam],[1,1,0,0]);
kk = kk.add_bind(rb_datasets,{2,[2,1],0.245});
kk = kk.set_bfun(rb_datasets,@testfunc_bkgd,[const,grad],[1,0]);
kk = kk.set_mc_points(10);
kk = kk.set_options('listing',nlist);
[ferb_tf_1,par_ferb_tf_1]=kk.fit;

fback = kk.simulate(par_ferb_tf_1,'back');
acolor k b r m g; dm(ferb(fe_datasets)); pl(ferb_tf_1(fe_datasets)); lx -1 1; ly 0 0.4
pl(fback(fe_datasets))
pause(2)
acolor k b r m g; dm(ferb(rb_datasets)); pl(ferb_tf_1(rb_datasets));
pl(fback(rb_datasets))


if test_output
    disp('Comparing with stored fit')
    if ~is_same_fit (par_ferb_tf_1,   tmp.par_ferb_tf_1,   fac)
        error('par_ferb_tf_1 not same')
    end
end


% %% --------------------------------------------------------------------------------------
% % Collect results together as a structure
% % ---------------------------------------------------------------------------------------
% 
% % Cuts
% res.fe = fe;
% res.rb = rb;
% res.ferb = ferb;
% 
% % Fe only fit
% res.fe_tf_1 = fe_tf_1;
% res.par_fe_tf_1 = par_fe_tf_1;
% 
% % Rb only fit
% res.rb_tf_1 = rb_tf_1;
% res.par_rb_tf_1 = par_rb_tf_1;
% 
% % Fe and Rb simultaneous fit
% res.ferb_tf_1 = ferb_tf_1;
% res.par_ferb_tf_1 = par_ferb_tf_1;



%% --------------------------------------------------------------------------------------
% Save fit parameter output if requested
% ---------------------------------------------------------------------------------------
if save_output
    save(fullfile(tempdir,savefile),...
        'par_fe_tf_1','par_rb_tf_1','par_ferb_tf_1');
end
