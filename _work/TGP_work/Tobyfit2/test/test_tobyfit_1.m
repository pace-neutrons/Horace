function res=test_tobyfit_1 (save_output)
% Test basic aspects of Tobyfit
%
%   >> res=test_tobyfit_1
%   >> res=test_tobyfit_1 (save_output)     % if save_output==true, save output to file
%                                           % fullfile(tempdir,'test_tobyfit_1.mat')

%% --------------------------------------------------------------------------------------
% Find version of Tobyfit
% Tobyfit2 and Tobyfit are mutually incompatible - Tobyfit only 

if ~isempty(which('tobyfit2_init')) && isempty(which('tobyfit_init'))
    tf_ver=2;
elseif ~isempty(which('tobyfit_init')) && isempty(which('tobyfit2_init'))
    tf_ver=1;
else
    error('Both or neither of Tobyfit and Tobyfit2 are present')
end

% Determine whether or not to save output
if exist('save_output','var')
    if islognumscalar(save_output)
        save_output=logical(save_output);
    else
        error('Check the optional argument ''save_output'' is a logical scalar')
    end
else
    save_output=false;
end


%% --------------------------------------------------------------------------------------
% Setup
% tf_dir=fileparts(which(mfilename));
% parfile='C:\data\Fe\9cards_4_4to1.par';

datafile='E:\data\Fe\sqw\Fe_ei787.sqw';

sample=IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.04,0.03,0.02]);


%% --------------------------------------------------------------------------------------
% Create single cuts
% --------------------------------------------------------------------------------------
% Short cut along [1,1,0]
% -----------------------
proj.u=[1,1,0];
proj.v=[-1,1,0];
w110a=cut_sqw(datafile,proj,[0.95,1.05],[-0.6,0.05,0.6],[-0.05,0.05],[150,160]);
w110a=set_sample_and_inst(w110a,sample,@maps_instrument,'-efix',600,'S');

% Long cut along [1,1,0]
% ----------------------
proj.u=[1,1,0];
proj.v=[-1,1,0];
w110b=cut_sqw(datafile,proj,[0.95,1.05],[-2,0.05,3],[-0.05,0.05],[150,160]);
w110b=set_sample_and_inst(w110b,sample,@maps_instrument,'-efix',600,'S');


%% --------------------------------------------------------------------------------------
% Create cuts to simulate or fit simultaneously
% --------------------------------------------------------------------------------------
proj.u=[1,1,0];
proj.v=[-1,1,0];
w110_1=cut_sqw(datafile,proj,[0.95,1.05],[-0.6,0.05,0.6],[-0.05,0.05],[140,160]);
w110_2=cut_sqw(datafile,proj,[0.95,1.05],[-0.6,0.05,0.6],[-0.05,0.05],[160,180]);
w110_3=cut_sqw(datafile,proj,[0.95,1.05],[-0.6,0.05,0.6],[-0.05,0.05],[180,200]);

w110_1 = set_sample_and_inst(w110_1,sample,@maps_instrument,'-efix',600,'S');
w110_2 = set_sample_and_inst(w110_2,sample,@maps_instrument,'-efix',600,'S');
w110_3 = set_sample_and_inst(w110_3,sample,@maps_instrument,'-efix',600,'S');

w110arr=[w110_1,w110_2,w110_3];


%% --------------------------------------------------------------------------------------
% Evaluate sqw and Tobyfit simulation for single cut
% --------------------------------------------------------------------------------------

% ---------------------------------------------------------------------------------------
% Short cut

amp=1;  sj=40;   fwhh=50;

% Evaluate S(Q,w) model
w110a_eval=sqw_eval(w110a,@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
acolor k; dd(w110a_eval)

% Tobyfit simulation
if tf_ver==1
    w110a_sim=tobyfit(w110a,@testfunc_sqw_bcc_hfm,[amp,sj,fwhh],'eval','mc_npoints',10);
else
    kk=tobyfit2(w110a);
    kk=kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
    kk=kk.set_mc_points(10);
    w110a_sim=kk.simulate;
end
acolor b; pd(w110a_sim)

pause(2)
% ---------------------------------------------------------------------------------------
% Long cut

amp=1;  sj=40;   fwhh=50;

% Evaluate S(Q,w) model
w110b_eval=sqw_eval(w110b,@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
acolor k; dd(w110b_eval)

% Tobyfit simulation
if tf_ver==1
    w110b_sim=tobyfit(w110b,@testfunc_sqw_bcc_hfm,[amp,sj,fwhh],'eval','mc_npoints',10);
else
    kk=tobyfit2(w110b);
    kk=kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
    kk=kk.set_mc_points(10);
    w110b_sim=kk.simulate;
end
acolor b; pd(w110b_sim)

pause(2)


%% --------------------------------------------------------------------------------------
% Fit single cuts
% --------------------------------------------------------------------------------------

% ---------------------------------------------------------------------------------------
% An example of having starting parameters close to a good fit

amp=50;  sj=40;   fwhh=50;   const=0.1;  grad=0;

if tf_ver==1
    w110a1_sim=tobyfit(w110a,@testfunc_sqw_bcc_hfm_bkgd,[amp,sj,fwhh,const,grad],'eval','mc_npoints',10);
else
    kk = tobyfit2(w110a);
    kk = kk.set_fun(@testfunc_sqw_bcc_hfm_bkgd,[amp,sj,fwhh,const,grad]);
    kk = kk.set_mc_points(10);
    w110a1_sim=kk.simulate;
end
acolor b; dd(w110a); acolor k; pl(w110a1_sim); ly 0 0.4

if tf_ver==1
    [w110a1_tf,fp110a1]=tobyfit(w110a,@testfunc_sqw_bcc_hfm_bkgd,[amp,sj,fwhh,const,grad],[1,0,0,1,0],'list',2,'mc_npoints',10);
else
    kk = tobyfit2(w110a);
    kk = kk.set_fun(@testfunc_sqw_bcc_hfm_bkgd,[amp,sj,fwhh,const,grad],[1,0,0,1,0]);
    kk = kk.set_mc_points(10);
    kk = kk.set_options('listing',2);
    [w110a1_tf,fp110a1]=kk.fit;
end
acolor r; pl(w110a1_tf); ly 0 0.4

pause(2)

% ---------------------------------------------------------------------------------------
% From a poor starting position
amp=100;  sj=40;   fwhh=50;   const=0;  grad=0;

if tf_ver==1
    w110a2_sim=tobyfit(w110a,@testfunc_sqw_bcc_hfm_bkgd,[amp,sj,fwhh,const,grad],'eval','mc_npoints',10);
else
    kk = tobyfit2(w110a);
    kk = kk.set_fun(@testfunc_sqw_bcc_hfm_bkgd,[amp,sj,fwhh,const,grad]);
    kk = kk.set_mc_points(10);
    w110a2_sim=kk.simulate;
end
acolor b; dd(w110a); acolor k; pl(w110a2_sim); ly 0 0.4

if tf_ver==1
    [w110a2_tf,fp110a2]=tobyfit(w110a,@testfunc_sqw_bcc_hfm_bkgd,[amp,sj,fwhh,const,grad],[1,0,0,1,0],'list',2,'mc_npoints',10);
else
    kk = tobyfit2(w110a);
    kk = kk.set_fun(@testfunc_sqw_bcc_hfm_bkgd,[amp,sj,fwhh,const,grad],[1,0,0,1,0]);
    kk = kk.set_mc_points(10);
    kk = kk.set_options('listing',2);
    [w110a2_tf,fp110a2]=kk.fit;
end
acolor r; pl(w110a2_tf); ly 0 0.4

pause(2)

% ---------------------------------------------------------------------------------------
% Decouple foreground and background - get same result, so good!
amp=100;  sj=40;   fwhh=50;   const=0;  grad=0;

if tf_ver==1
    w110a3_sim=tobyfit(w110a,@testfunc_sqw_bcc_hfm,[amp,sj,fwhh],@testfunc_bkgd,[const,grad],'eval','mc_npoints',10);
else
    kk = tobyfit2(w110a);
    kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh,const,grad]);
    kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
    kk = kk.set_mc_points(10);
    w110a3_sim=kk.simulate;
end
acolor b; dd(w110a); acolor k; pl(w110a3_sim); ly 0 0.4

if tf_ver==1
    [w110a3_tf,fp110a3]=tobyfit(w110a,@testfunc_sqw_bcc_hfm,[amp,sj,fwhh],[1,0,0],@testfunc_bkgd,[const,grad],[1,0],'list',2,'mc_npoints',10);
else
    kk = tobyfit2(w110a);
    kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
    kk = kk.set_free([1,0,0]);
    kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
    kk = kk.set_bfree([1,0]);
    kk = kk.set_mc_points(10);
    kk = kk.set_options('listing',2);
    [w110a3_tf,fp110a3]=kk.fit;
end
acolor r; pl(w110a3_tf); ly 0 0.4

pause(2)

% ---------------------------------------------------------------------------------------
% Allow all parameters to vary
amp=100;  sj=40;   fwhh=50;   const=0;  grad=0;

if tf_ver==1
    w110a4_sim=tobyfit(w110a,@testfunc_sqw_bcc_hfm,[amp,sj,fwhh],@testfunc_bkgd,[const,grad],'eval','mc_npoints',10);
else
    kk = tobyfit2(w110a);
    kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh,const,grad]);
    kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
    kk = kk.set_mc_points(10);
    w110a4_sim=kk.simulate;
end
acolor b; dd(w110a); acolor k; pl(w110a4_sim); ly 0 0.4

if tf_ver==1
    [w110a4_tf,fp110a4]=tobyfit(w110a,@testfunc_sqw_bcc_hfm,[amp,sj,fwhh],@testfunc_bkgd,[const,grad],'list',2,'mc_npoints',10);
else
    kk = tobyfit2(w110a);
    kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
    kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
    kk = kk.set_mc_points(10);
    kk = kk.set_options('listing',2);
    [w110a4_tf,fp110a4]=kk.fit;
end
acolor r; pl(w110a4_tf); ly 0 0.4

pause(2)


%% --------------------------------------------------------------------------------------
% Fit multiple datasets
% ---------------------------------------------------------------------------------------

% ---------------------------------------------------------------------------------------
% Global foreground; allow all parameters to vary
amp=100;  sj=40;   fwhh=50;   const=0;  grad=0;

if tf_ver==1
    w110arr1_sim=tobyfit(w110arr,@testfunc_sqw_bcc_hfm,[amp,sj,fwhh],@testfunc_bkgd,[const,grad],'eval');
else
    kk = tobyfit2(w110arr);
    kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
    kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
    kk = kk.set_mc_points(10);
    w110arr1_sim=kk.simulate;
end
acolor k b r; dp(w110arr); pl(w110arr1_sim); ly 0 0.8


if tf_ver==1
    [w110arr1_tf,fp110arr1]=tobyfit(w110arr,@testfunc_sqw_bcc_hfm,[amp,sj,fwhh],[1,1,1],@testfunc_bkgd,[const,grad],[1,1],'list',3);
    acolor k b r; dp(w110arr); pl(w110arr1_tf); ly 0 0.4
else
    kk = tobyfit2(w110arr);
    kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
    kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
    kk = kk.set_mc_points(10);
    kk = kk.set_options('listing',3);
    [w110arr1_tf,fp110arr1]=kk.fit;
    
    acolor k b r; dp(w110arr); pl(w110arr1_tf); ly 0 0.4
    fback = kk.simulate(fp110arr1,'back');
    pl(fback)
end
acolor k b r; dp(w110arr); pl(w110arr1_tf); ly 0 0.4

pause(2)

% ---------------------------------------------------------------------------------------
% Local foreground; constrain SJ as global but allow amplitude and gamma to vary locally
amp=100;  sj=40;   fwhh=50;   const=0;  grad=0;

if tf_ver==1
    w110arr2_sim=tobyfit(w110arr,@testfunc_sqw_bcc_hfm,[amp,sj,fwhh],@testfunc_bkgd,[const,grad],'eval');
else
    kk = tobyfit2(w110arr);
    kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
    kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
    kk = kk.set_mc_points(10);
    w110arr2_sim=kk.simulate;
end
acolor k b r; dp(w110arr); pl(w110arr2_sim); ly 0 0.8

if tf_ver==1
    pbind = multifit_bind_local_pars_as_global (size(w110arr), [0,1,0], true);
    [w110arr2_tf,fp110arr2]=tobyfit(w110arr,@testfunc_sqw_bcc_hfm,[amp,sj,fwhh],[],pbind,...
        @testfunc_bkgd,[const,grad],'local_fore','list',3,'mc_npoints',10);
    acolor k b r; dp(w110arr); pl(w110arr2_tf); ly 0 0.4
else
    kk = tobyfit2(w110arr);
    kk = kk.set_local_foreground;
    kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
    kk = kk.set_bind({2,[2,1]});
    kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
    kk = kk.set_mc_points(10);
    kk = kk.set_options('listing',3);
    [w110arr2_tf,fp110arr2]=kk.fit;
    
    acolor k b r; dp(w110arr); pl(w110arr2_tf); ly 0 0.4
    fback = kk.simulate(fp110arr2,'back');
    pl(fback)
end

pause(2)


%% --------------------------------------------------------------------------------------
% Collect results together as a structure
% ---------------------------------------------------------------------------------------

% Cuts
res.w110a=w110a;
res.w110b=w110b;
res.w110arr=w110arr;

% First simulations
res.w110a_eval=w110a_eval;
res.w110a_sim=w110a_sim;

res.w110b_eval=w110b_eval;
res.w110b_sim=w110b_sim;

% Fits to single cuts
res.w110a1_sim=w110a1_sim;
res.w110a1_tf=w110a1_tf;
res.fp110a1=fp110a1;

res.w110a2_sim=w110a2_sim;
res.w110a2_tf=w110a2_tf;
res.fp110a2=fp110a2;

res.w110a3_sim=w110a3_sim;
res.w110a3_tf=w110a3_tf;
res.fp110a3=fp110a3;

res.w110a4_sim=w110a4_sim;
res.w110a4_tf=w110a4_tf;
res.fp110a4=fp110a4;

% Fits to multiple cuts
res.w110arr1_sim=w110arr1_sim;
res.w110arr1_tf=w110arr1_tf;
res.fp110arr1=fp110arr1;

res.w110arr2_sim=w110arr2_sim;
res.w110arr2_tf=w110arr2_tf;
res.fp110arr2=fp110arr2;

if save_output
    save(fullfile(tempdir,'test_tobyfit_1.mat'),'res');
end

