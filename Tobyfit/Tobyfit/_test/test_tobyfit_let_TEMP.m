%% --------------------------------------------------------------------------------------
% Setup
% --------------------------------------------------------------------------------------

dir_in='T:\data\Tobyfit_test';
dir_out=tempdir;

% Output files with simulated data to be corrected
sqw_file='tobyfit_let_test.sqw';


%% --------------------------------------------------------------------------------------
% Read or create sqw file for refinement test
% --------------------------------------------------------------------------------------

efix=8;
emode=1;
en0=-3:0.02:7;
en=-2:0.02:2;
par_file=fullfile(pwd,'LET_one2one_153.par');

% Parameters for reference lattice (i.e. what we think we have)
alatt=[5,5,5];
angdeg=[90,90,90];
u=[1,1,0];
v=[0,0,1];
psi0=180;
psi=180:1:270;
omega=0; dpsi=0; gl=0; gs=0;

if save_data
    % Create sqw file for refinement testing
    % ---------------------------------------
    % Full output file names
    sqw_file_full = fullfile(dir_out,sqw_file);
    
    % Create sqw file for single spe file
    fake_sqw (en0, par_file, sqw_file_full, efix, emode, alatt, angdeg, u, v, psi0, omega, dpsi, gl, gs);
    
    if nargout>0
        varargout{1}=true;
    end
    return
    
else
    sqw_file_full = fullfile(dir_in,sqw_file);
    
    if ~exist(sqw_file_full,'file')
        error('Input sqw file for tests does not exist')
    end
end

%% --------------------------------------------------------------------------------------
% Read or create sqw file for refinement test
% --------------------------------------------------------------------------------------
% mod FWHH=99.37us, shape_chop FWHH=162.4us
instru = let_instrument (efix, 280, 140, 20, 2, 2);
samp = IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);

proj1.u = [1,1,0];
proj1.v = [0,0,1];

w1 = cut_sqw (sqw_file_full, proj1, [-0.5,0], [0.5,1], [-0.2,0.2], [-3.01,0.02,7.01]);

w2 = set_instrument (w1, instru);
w2 = set_sample (w2, samp);

% Simulate with vanadium
wref0 = sqw_eval(w2,@van_sqw,[10,0,0.05]);

kk = tobyfit (wref0,'disk');

kk = kk.set_fun(@van_sqw,[10,0,0.05]);
kk = kk.set_mc_points(10);

% Problem: all points masked (zero error bars) which screws things up:
wsim = kk.simulate;

% Add error bars
wref = noisify(wref0,1);
instru_fermi = maps_instrument(8,50,'S');
wref_fermi = set_instrument(wref, instru_fermi);

% Simulate
kk = tobyfit (wref,'disk');
kk = kk.set_fun(@van_sqw,[10,0,0.05]);
kk = kk.set_mc_points(10);
wsim = kk.simulate;

kkf = tobyfit (wref_fermi,'fermi');
kkf = kkf.set_fun(@van_sqw,[10,0,0.05]);
kkf = kkf.set_mc_points(10);
wsim_fermi = kkf.simulate;

kk = tobyfit (wref,'disk_test');
kk = kk.set_fun(@van_sqw,[10,0,0.05]);
kk = kk.set_mc_points(10);
wsim_test = kk.simulate;

kkft = tobyfit (wref_fermi,'fermi_test');
kkft = kkft.set_fun(@van_sqw,[10,0,0.05]);
kkft = kkft.set_mc_points(10);
wsim_fermi_test = kkft.simulate;

%% ====================================================================================================
% Test the mod/shape chop pulse width
% -----------------------------------
% To access the distribution of sampling times from the joint moderator/chopper 1 
% deviate, need to use the debugger and inside the function tobyfit_DGdisk_resconv
% pause and use the saver script to save y(1,1,:)

% mod FWHH=99.37us, shape_chop FWHH=66.48us
% Will have pulse determined by moderator
instru_mod = let_instrument (efix, 280, 140, 20, 2, 2);
instru_mod.chop_shape.frequency=171;
wtmp=set_instrument(wref, instru_mod);

% mod FWHH=99.37us, shape_chop FWHH=66.09us
% Will have pulse determined by shaping chopper
instru_shape = let_instrument (efix, 280, 140, 20, 2, 2);
instru_shape.chop_shape.frequency=172;
wtmp=set_instrument(wref, instru_shape);

% mod FWHH=99.37us, shape_chop FWHH=11368us
instru_mod_only = let_instrument (efix, 280, 140, 20, 2, 2);
instru_mod_only.chop_shape.frequency=1;
wtmp=set_instrument(wref, instru_mod_only);

% mod FWHH=33947us, shape_chop FWHH=66.48us
instru_shape_only = let_instrument (efix, 280, 140, 20, 2, 2);
instru_shape_only.moderator.pp(1)=10000;
instru_shape_only.chop_shape.frequency=171;
wtmp=set_instrument(wref, instru_shape_only);



% Simulation script
kk = tobyfit2 (wtmp,'disk');
kk = kk.set_fun(@van_sqw,[10,0,0.05]);
kk = kk.set_mc_points(10);
wsim = kk.simulate;

%*********
% Saver script to use in debug:
tm=yvec(1,1,:);
[nn,ee]=histcounts(tm);
ww=IX_dataset_1d(ee,nn);
save('shape_only.mat','ww')
%*********



%% ====================================================================================================
% Test the contributions
% ----------------------
instru = let_instrument (efix, 280, 140, 20, 2, 2);
samp = IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);

proj1.u = [1,1,0];
proj1.v = [0,0,1];

w1 = cut_sqw (sqw_file_full, proj1, [-0.5,0], [0.5,1], [-0.2,0.2], [-1.01,0.02,1.01]);
w1 = set_instrument (w1, instru);
w1 = set_sample (w1, samp);

wref = sqw_eval(w1,@van_sqw,[10,0,0.05]);   % 50 ueV fwhh; peak_cwhh gives 54
wref = noisify(wref,1);     % add error bars


kk = tobyfit2 (wref,'disk');
kk = kk.set_fun(@van_sqw,[10,0,0.05]);
kk = kk.set_mc_points(10);


% All contributions
% -----------------------------------
% All contributions: fwhh = 204 ueV
kk=kk.set_mc_contributions('all');
wsim_all = kk.simulate;
[xcent,xpeak,fwhh,xneg,xpos,ypeak,wpeak]=peak_cwhh(IX_dataset_1d(wsim_all));



% Individual contributions
% ------------------------------

% No contributions: fwhh = 54 ueV
kk=kk.set_mc_contributions('none');
wsim_none = kk.simulate;
[xcent,xpeak,fwhh,xneg,xpos,ypeak,wpeak]=peak_cwhh(IX_dataset_1d(wsim_none));

% Moderator & shape chopper only: fwhh = 123 ueV
kk=kk.set_mc_contributions('none');
kk=kk.set_mc_contributions('moderator','shape_chopper');
wsim_shape = kk.simulate;
[xcent,xpeak,fwhh,xneg,xpos,ypeak,wpeak]=peak_cwhh(IX_dataset_1d(wsim_shape));

% Mono chopper only: fwhh = 169 ueV
kk=kk.set_mc_contributions('none');
kk=kk.set_mc_contributions('mono_chopper');
wsim_mono = kk.simulate;
[xcent,xpeak,fwhh,xneg,xpos,ypeak,wpeak]=peak_cwhh(IX_dataset_1d(wsim_mono));

% Moderator & both chopper only: fwhh = 192 ueV
kk=kk.set_mc_contributions('none');
kk=kk.set_mc_contributions('moderator','shape_chopper','mono_chopper');
wsim_chops = kk.simulate;
[xcent,xpeak,fwhh,xneg,xpos,ypeak,wpeak]=peak_cwhh(IX_dataset_1d(wsim_chops));

% Divergence only: fwhh = 54 ueV
kk=kk.set_mc_contributions('none');
kk=kk.set_mc_contributions('horiz','vert');
wsim_div = kk.simulate;
[xcent,xpeak,fwhh,xneg,xpos,ypeak,wpeak]=peak_cwhh(IX_dataset_1d(wsim_div));

% Sample only: fwhh = 77 ueV
kk=kk.set_mc_contributions('none');
kk=kk.set_mc_contributions('sample');
wsim_sam = kk.simulate;
[xcent,xpeak,fwhh,xneg,xpos,ypeak,wpeak]=peak_cwhh(IX_dataset_1d(wsim_sam));

% Detector depth only: fwhh = 67 ueV
kk=kk.set_mc_contributions('none');
kk=kk.set_mc_contributions('detector_depth');
wsim_dd = kk.simulate;
[xcent,xpeak,fwhh,xneg,xpos,ypeak,wpeak]=peak_cwhh(IX_dataset_1d(wsim_dd));

% Detector area only: fwhh = 54 ueV
kk=kk.set_mc_contributions('none');
kk=kk.set_mc_contributions('detector_area');
wsim_da = kk.simulate;
[xcent,xpeak,fwhh,xneg,xpos,ypeak,wpeak]=peak_cwhh(IX_dataset_1d(wsim_da));

% Energy bins only: fwhh = 56 ueV
kk=kk.set_mc_contributions('none');
kk=kk.set_mc_contributions('energy_bin');
wsim_ebin = kk.simulate;
[xcent,xpeak,fwhh,xneg,xpos,ypeak,wpeak]=peak_cwhh(IX_dataset_1d(wsim_ebin));



% Determine effect of dual moderator pulse and shaping chopper:
% -------------------------------------------------------------
% All contributions: fwhh = 205 ueV
kk=kk.set_mc_contributions('all');
wsim_all = kk.simulate;
[xcent,xpeak,fwhh,xneg,xpos,ypeak,wpeak]=peak_cwhh(IX_dataset_1d(wsim_all));


% No shaping chopper: fwhh = 209 ueV
kk=kk.set_mc_contributions('noshape');
wsim_all = kk.simulate;
[xcent,xpeak,fwhh,xneg,xpos,ypeak,wpeak]=peak_cwhh(IX_dataset_1d(wsim_all));


% No moderator pulse: fwhh = 347 ueV
kk=kk.set_mc_contributions('nomod');
wsim_all = kk.simulate;
[xcent,xpeak,fwhh,xneg,xpos,ypeak,wpeak]=peak_cwhh(IX_dataset_1d(wsim_all));


%% ====================================================================================================
% Test the q-resolution width
% ---------------------------

% Suitable cut to simulate rods of intensity
wq2 = cut_sqw (sqw_file_full, proj1, 0.025, 0.025, [-0.2,0.2], [-3,6]);
wq1 = cut_sqw (sqw_file_full, proj1, [-0.2,0.2], [-0.3,0.02,0.3], [-0.2,0.2], [-3,6]);

instru = let_instrument (efix, 280, 140, 20, 2, 2);
samp = IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);
wq1 = set_instrument (wq1, instru);
wq1 = set_sample (wq1, samp);

% Test the cross-section model
fwhh = 0.25;
wq2_nores=sqw_eval(wq2,@sheet_sqw,{[1,fwhh],[5,5,5,90,90,90],[0,0,1]});
wq1_nores=sqw_eval(wq1,@sheet_sqw,{[1,fwhh],[5,5,5,90,90,90],[0,0,1]});


% Now test resolution
fwhh = 0.02;
wnores = sqw_eval(wq1,@sheet_sqw,{[1,fwhh],[5,5,5,90,90,90],[0,0,1]});

kk = tobyfit(wq1,'disk');
kk = kk.set_fun(@sheet_sqw,{[1,fwhh],[5,5,5,90,90,90],[0,0,1]});
kk = kk.set_mc_points(10);
kk = kk.set_mc_contributions('horiz');      % horizontal divergence only
wsim = kk.simulate;

kkt = tobyfit (wq1,'disk_test');
kkt = kkt.set_fun(@sheet_sqw,{[1,fwhh],[5,5,5,90,90,90],[0,0,1]});
kkt = kkt.set_mc_points(10);
kkt = kkt.set_mc_contributions('horiz');    % horizontal divergence only
wsim_test = kkt.simulate;


% % FWHH in Q
% fwhh = 0.01;
% wq1_nores=sqw_eval(wq1,@rod_sqw,{[1,fwhh],[5,5,5,90,90,90]});
% 
% % Now with resolution
% kk = tobyfit(wq1,'disk');
% kk = kk.set_fun(@rod_sqw,{[1,fwhh],[5,5,5,90,90,90]});
% kk = kk.set_mc_points(10);
% kk = kk.set_mc_contributions('horiz');      % horizontal divergence only
% wsim = kk.simulate;
% 
% kkt = tobyfit (wq1,'disk_test');
% kkt = kkt.set_fun(@rod_sqw,{[1,fwhh],[5,5,5,90,90,90]});
% kkt = kkt.set_mc_points(10);
% kkt = kkt.set_mc_contributions('horiz');    % horizontal divergence only
% wsim_test = kkt.simulate;







