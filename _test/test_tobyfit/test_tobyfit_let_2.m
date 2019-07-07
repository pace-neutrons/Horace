function varargout=test_tobyfit_let_2 (option)
% Test basic aspects of Tobyfit
%
% Setup (should only have to do in extremis):
%
% Perform tests:
%   >> test_tobyfit_let_2           % Run the Tobyfit tests and test against stored fit
%                                   % parameters in test_tobyfit_let_2_out.mat in the same
%                                   % folder as this file
%
%   >> test_tobyfit_let_2 ('-save') % Run the Tobyfit tests and save fit parameters
%                                   % to file test_tobyfit_let_2_out.mat
%                                   % in the temporary folder (given by tempdir)
%                                   % Copy to the same folder as this file to use in
%                                   % tests.
%
%   >> test_tobyfit_let_2 ('-notest')   % Run without testing against previously stored results.
%                                       % For performing visual checks or debugging the tests!
%
% In all of the above, get the full output of the fits as a structure:
%
%   >> res = test_tobyfit_2 (...)

% ----------------------------------------------------------------------------
% Setup (should only have to do in extremis - assumes data on Toby Perring's computer
%   >> test_tobyfit_let_2 ('-setup')% Create the cuts that will be fitted and save in
%                                   % test_tobyfit_let_2_data.mat in the temporary folder
%                                   % given by tempdir. Copy this file to the same folder
%                                   % that holds this .m file to use it in the following
%                                   % tests
%   >> status = test_tobyfit_let_2 ('-setup')


%% --------------------------------------------------------------------------------------
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
% --------------------------------------------------------------------------------------
% Filename for temporary creation of simulated sqw data
sqw_file='test_tobyfit_let_2.sqw';

% Output file with simulated data to be corrected
datafile='test_tobyfit_let_2_data.mat';      

% Filename to which saved results are written
savefile='test_tobyfit_let_2_out.mat';      

error_on_failure = false;

%% --------------------------------------------------------------------------------------
% Read or create sqw file for refinement test
% --------------------------------------------------------------------------------------

efix=8;
emode=1;
en0=-3:0.02:7;
%en=-2:0.02:2;
par_file=fullfile(pwd,'LET_one2one_153.par');

% Parameters for reference lattice (i.e. what we think we have)
alatt=[5,5,5];
angdeg=[90,90,90];
u=[1,1,0];
v=[0,0,1];
psi0=180;
%psi=180:1:270;
omega=0; dpsi=0; gl=0; gs=0;

if save_data
    % Create sqw file for refinement testing
    % ---------------------------------------
    % Full output file names
    sqw_file_full = fullfile(tempdir,sqw_file);
    
    % Create sqw file for single spe file
    fake_sqw (en0, par_file, sqw_file_full, efix, emode, alatt, angdeg, u, v, psi0, omega, dpsi, gl, gs);
    
    % Create cut
    proj = projaxes([1,1,0],[0,0,1]);
    w1 = cut_sqw (sqw_file_full, proj, [-0.5,0], [0.5,1], [-0.2,0.2], [-3.01,0.02,7.01]);
    
    % Save cut for future use
    datafile_full = fullfile(tempdir,datafile);
    save(datafile_full,'w1');
    disp(['Saved data for future use in',datafile_full])
    if nargout>0
        varargout{1}=true;
    end
    return
    
else
    % Read in data
    load(datafile);
end


%% --------------------------------------------------------------------------------------
% Read test results if necessary
% --------------------------------------------------------------------------------------
if test_output
    tmp=load(savefile);
end


%% --------------------------------------------------------------------------------------
% Read or create sqw file for refinement test
% --------------------------------------------------------------------------------------
% mod FWHH=99.37us, shape_chop FWHH=162.4us
instru = let_instrument_obj_for_tests (efix, 280, 140, 20, 2, 2);
samp = IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);

w1 = set_instrument (w1, instru);
w1 = set_sample (w1, samp);

% Simulate with vanadium lineshape
wref = sqw_eval(w1,@van_sqw,[10,0,0.05]);   % 50 ueV fwhh; peak_cwhh gives 54
wref = noisify(wref,1);     % add error bars


%% ====================================================================================================
% Test the mod/shape chop pulse width
% -----------------------------------
% To access the distribution of sampling times from the joint moderator/chopper 1 
% deviate, need to use the debugger and inside the function tobyfit_DGdisk_resconv
% pause and use the saver script to save y(1,1,:)

% mod FWHH=99.37us, shape_chop FWHH=66.48us
% Will have pulse determined by moderator
instru_mod = let_instrument_obj_for_tests (efix, 280, 140, 20, 2, 2);
instru_mod.shaping_chopper.frequency=171;
wtmp=set_instrument(wref, instru_mod);

whist_1 = get_tshape_histogram (wtmp);
[~,~,fwhh_1] = peak_cwhh(whist_1);
if test_output
    disp('Comparing with stored whist_1')
    if ~IX_dataset_1d_same(whist_1,tmp.whist_1,1.2,'chisqr','rebin')
        error_test (error_on_failure, 'Histograms not equivalent')
    end
    if ~equal_to_tol(fwhh_1, tmp.fwhh_1, [0,0.03])
        error_test (error_on_failure, 'fwhh not equivalent')
    end
end

% mod FWHH=99.37us, shape_chop FWHH=66.09us
% Will have pulse determined by shaping chopper
instru_shape = let_instrument_obj_for_tests (efix, 280, 140, 20, 2, 2);
instru_shape.shaping_chopper.frequency=172;
wtmp=set_instrument(wref, instru_shape);

whist_2 = get_tshape_histogram (wtmp);
[~,~,fwhh_2] = peak_cwhh(whist_2);
if test_output
    disp('Comparing with stored whist_2')
    if ~IX_dataset_1d_same(whist_2,tmp.whist_2,1.2,'chisqr','rebin')
        error_test (error_on_failure, 'Histograms not equivalent')
    end
    if ~equal_to_tol(fwhh_2, tmp.fwhh_2, [0,0.03])
        error_test (error_on_failure, 'fwhh not equivalent')
    end
end

% mod FWHH=99.37us, shape_chop FWHH=11368us
instru_mod_only = let_instrument_obj_for_tests (efix, 280, 140, 20, 2, 2);
instru_mod_only.shaping_chopper.frequency=1;
wtmp=set_instrument(wref, instru_mod_only);

whist_3 = get_tshape_histogram (wtmp);
[~,~,fwhh_3] = peak_cwhh(whist_3);
if test_output
    disp('Comparing with stored whist_3')
    if ~IX_dataset_1d_same(whist_3,tmp.whist_3,1.2,'chisqr','rebin')
        error_test (error_on_failure, 'Histograms not equivalent')
    end
    if ~equal_to_tol(fwhh_3, tmp.fwhh_3, [0,0.03])
        error_test (error_on_failure, 'fwhh not equivalent')
    end
end

% mod FWHH=33947us, shape_chop FWHH=66.48us
instru_shape_only = let_instrument_obj_for_tests (efix, 280, 140, 20, 2, 2);
instru_shape_only.moderator.pp(1)=10000;
instru_shape_only.shaping_chopper.frequency=171;
wtmp=set_instrument(wref, instru_shape_only);

whist_4 = get_tshape_histogram (wtmp);
[~,~,fwhh_4] = peak_cwhh(whist_4);
if test_output
    disp('Comparing with stored whist_4')
    if ~IX_dataset_1d_same(whist_4,tmp.whist_4,1.2,'chisqr','rebin')
        error_test (error_on_failure, 'Histograms not equivalent')
    end
    if ~equal_to_tol(fwhh_4, tmp.fwhh_4, [0,0.03])
        error_test (error_on_failure, 'fwhh not equivalent')
    end
end


%% ====================================================================================================
% Test the contributions
% ----------------------

kk = tobyfit (wref);
kk = kk.set_fun(@van_sqw,[10,0,0.05]);
kk = kk.set_mc_points(10);


% All contributions
% -----------------------------------
% All contributions: fwhh = 204 ueV
kk=kk.set_mc_contributions('all');
wsim_all = kk.simulate;
[xcent,xpeak,fwhh_all,xneg,xpos,ypeak,wpeak]=peak_cwhh(IX_dataset_1d(wsim_all));
if test_output
    disp('Comparing with stored fwhh_all')
    if ~equal_to_tol(fwhh_all, tmp.fwhh_all, [0,0.03])
        error_test (error_on_failure, 'fwhh_all not equivalent')
    end
end


% Individual contributions
% ------------------------------
% No contributions: fwhh = 54 ueV
kk=kk.set_mc_contributions('none');
wsim_none = kk.simulate;
[xcent,xpeak,fwhh_none,xneg,xpos,ypeak,wpeak]=peak_cwhh(IX_dataset_1d(wsim_none));
if test_output
    disp('Comparing with stored fwhh_none')
    if ~equal_to_tol(fwhh_none, tmp.fwhh_none, [0,0.03])
        error_test (error_on_failure, 'fwhh_none not equivalent')
    end
end

% Moderator & shape chopper only: fwhh = 123 ueV
kk=kk.set_mc_contributions('none');
kk=kk.set_mc_contributions('moderator','shape_chopper');
wsim_shape = kk.simulate;
[xcent,xpeak,fwhh_mod_and_shape,xneg,xpos,ypeak,wpeak]=peak_cwhh(IX_dataset_1d(wsim_shape));
if test_output
    disp('Comparing with stored fwhh_mod_and_shape')
    if ~equal_to_tol(fwhh_mod_and_shape, tmp.fwhh_mod_and_shape, [0,0.03])
        error_test (error_on_failure, 'fwhh_mod_and_shape not equivalent')
    end
end

% Mono chopper only: fwhh = 169 ueV
kk=kk.set_mc_contributions('none');
kk=kk.set_mc_contributions('mono_chopper');
wsim_mono = kk.simulate;
[xcent,xpeak,fwhh_mono,xneg,xpos,ypeak,wpeak]=peak_cwhh(IX_dataset_1d(wsim_mono));
if test_output
    disp('Comparing with stored fwhh_mono')
    if ~equal_to_tol(fwhh_mono, tmp.fwhh_mono, [0,0.03])
        error_test (error_on_failure, 'fwhh_mono not equivalent')
    end
end

% Moderator & both chopper only: fwhh = 192 ueV
kk=kk.set_mc_contributions('none');
kk=kk.set_mc_contributions('moderator','shape_chopper','mono_chopper');
wsim_chops = kk.simulate;
[xcent,xpeak,fwhh_mod_and_chops,xneg,xpos,ypeak,wpeak]=peak_cwhh(IX_dataset_1d(wsim_chops));
if test_output
    disp('Comparing with stored fwhh_mod_and_chops')
    if ~equal_to_tol(fwhh_mod_and_chops, tmp.fwhh_mod_and_chops, [0,0.03])
        error_test (error_on_failure, 'fwhh_mod_and_chops not equivalent')
    end
end

% Divergence only: fwhh = 54 ueV
kk=kk.set_mc_contributions('none');
kk=kk.set_mc_contributions('horiz','vert');
wsim_div = kk.simulate;
[xcent,xpeak,fwhh_div,xneg,xpos,ypeak,wpeak]=peak_cwhh(IX_dataset_1d(wsim_div));
if test_output
    disp('Comparing with stored fwhh_div')
    if ~equal_to_tol(fwhh_div, tmp.fwhh_div, [0,0.03])
        error_test (error_on_failure, 'fwhh_div not equivalent')
    end
end

% Sample only: fwhh = 77 ueV
kk=kk.set_mc_contributions('none');
kk=kk.set_mc_contributions('sample');
wsim_sam = kk.simulate;
[xcent,xpeak,fwhh_samp,xneg,xpos,ypeak,wpeak]=peak_cwhh(IX_dataset_1d(wsim_sam));
if test_output
    disp('Comparing with stored fwhh_samp')
    if ~equal_to_tol(fwhh_samp, tmp.fwhh_samp, [0,0.03])
        error_test (error_on_failure, 'fwhh_samp not equivalent')
    end
end

% Detector depth only: fwhh = 67 ueV
kk=kk.set_mc_contributions('none');
kk=kk.set_mc_contributions('detector_depth');
wsim_dd = kk.simulate;
[xcent,xpeak,fwhh_detdepth,xneg,xpos,ypeak,wpeak]=peak_cwhh(IX_dataset_1d(wsim_dd));
if test_output
    disp('Comparing with stored fwhh_detdepth')
    if ~equal_to_tol(fwhh_detdepth, tmp.fwhh_detdepth, [0,0.03])
        error_test (error_on_failure, 'fwhh_detdepth not equivalent')
    end
end

% Detector area only: fwhh = 54 ueV
kk=kk.set_mc_contributions('none');
kk=kk.set_mc_contributions('detector_area');
wsim_da = kk.simulate;
[xcent,xpeak,fwhh_detarea,xneg,xpos,ypeak,wpeak]=peak_cwhh(IX_dataset_1d(wsim_da));
if test_output
    disp('Comparing with stored fwhh_detarea')
    if ~equal_to_tol(fwhh_detarea, tmp.fwhh_detarea, [0,0.03])
        error_test (error_on_failure, 'fwhh_detarea not equivalent')
    end
end

% Energy bins only: fwhh = 56 ueV
kk=kk.set_mc_contributions('none');
kk=kk.set_mc_contributions('energy_bin');
wsim_ebin = kk.simulate;
[xcent,xpeak,fwhh_ebin,xneg,xpos,ypeak,wpeak]=peak_cwhh(IX_dataset_1d(wsim_ebin));
if test_output
    disp('Comparing with stored fwhh_ebin')
    if ~equal_to_tol(fwhh_ebin, tmp.fwhh_ebin, [0,0.03])
        error_test (error_on_failure, 'fwhh_ebin not equivalent')
    end
end



% Determine effect of dual moderator pulse and shaping chopper:
% -------------------------------------------------------------
% All constributions give a width of 204 ueV. Paradoxically removing either
% the shaping chopper or moderator results in a grater width. This is
% because the pulse width at the shaping chopper is  made bigger.

% No shaping chopper: fwhh = 209 ueV
kk=kk.set_mc_contributions('noshape');
wsim_all = kk.simulate;
[xcent,xpeak,fwhh_noshape,xneg,xpos,ypeak,wpeak]=peak_cwhh(IX_dataset_1d(wsim_all));
if test_output
    disp('Comparing with stored fwhh_noshape')
    if ~equal_to_tol(fwhh_noshape, tmp.fwhh_noshape, [0,0.03])
        error_test (error_on_failure, 'fwhh_noshape not equivalent')
    end
end



% No moderator pulse: fwhh = 347 ueV
kk=kk.set_mc_contributions('nomod');
wsim_all = kk.simulate;
[xcent,xpeak,fwhh_nomod,xneg,xpos,ypeak,wpeak]=peak_cwhh(IX_dataset_1d(wsim_all));
if test_output
    disp('Comparing with stored fwhh_nomod')
    if ~equal_to_tol(fwhh_nomod, tmp.fwhh_nomod, [0,0.03])
        error_test (error_on_failure, 'fwhh_nomod not equivalent')
    end
end



%% ====================================================================================================
% Test the q-resolution width
% ---------------------------

% Suitable cut to simulate rods of intensity
% wq2 = cut_sqw (sqw_file_full, proj, 0.025, 0.025, [-0.2,0.2], [-3,6]);
% wq1 = cut_sqw (sqw_file_full, proj, [-0.2,0.2], [-0.3,0.02,0.3], [-0.2,0.2], [-3,6]);
% 
% instru = let_instrument (efix, 280, 140, 20, 2, 2);
% samp = IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);
% wq1 = set_instrument (wq1, instru);
% wq1 = set_sample (wq1, samp);
% 
% % Test the cross-section model
% fwhh = 0.25;
% wq2_nores=sqw_eval(wq2,@sheet_sqw,{[1,fwhh],[5,5,5,90,90,90],[0,0,1]});
% wq1_nores=sqw_eval(wq1,@sheet_sqw,{[1,fwhh],[5,5,5,90,90,90],[0,0,1]});
% 
% 
% % Now test resolution
% fwhh = 0.02;
% wnores = sqw_eval(wq1,@sheet_sqw,{[1,fwhh],[5,5,5,90,90,90],[0,0,1]});
% 
% kk = tobyfit(wq1);
% kk = kk.set_fun(@sheet_sqw,{[1,fwhh],[5,5,5,90,90,90],[0,0,1]});
% kk = kk.set_mc_points(10);
% kk = kk.set_mc_contributions('horiz');      % horizontal divergence only
% wsim = kk.simulate;


% % FWHH in Q
% fwhh = 0.01;
% wq1_nores=sqw_eval(wq1,@rod_sqw,{[1,fwhh],[5,5,5,90,90,90]});
% 
% % Now with resolution
% kk = tobyfit(wq1);
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



%% --------------------------------------------------------------------------------------
% Save fit parameter output if requested
% ---------------------------------------------------------------------------------------
if save_output
    save(fullfile(tempdir,savefile),...
        'whist_1','fwhh_1','whist_2','fwhh_2','whist_3','fwhh_3','whist_4','fwhh_4',...
        'fwhh_all', 'fwhh_none', 'fwhh_mod_and_shape', 'fwhh_mono',...
        'fwhh_mod_and_chops', 'fwhh_div', 'fwhh_samp',...
        'fwhh_detdepth', 'fwhh_detarea', 'fwhh_ebin', 'fwhh_noshape', 'fwhh_nomod');
end

end


%% -----------------------------------------------------------------------------------------
function error_test (error_on_failure, mess)
if error_on_failure
    error(mess)
else
    disp(mess)
end

end


%% -----------------------------------------------------------------------------------------
function [whist, wsim] = get_tshape_histogram (wtmp)
% Get a histogram of the distribution of t_shape

debugtools('on')

kk = tobyfit (wtmp);
kk = kk.set_fun(@van_sqw,[10,0,0.05]);
kk = kk.set_mc_points(1);
wsim = kk.simulate;

tmp = load(fullfile(tempdir,'histogram.mat'));
whist = tmp.w;

debugtools('off')

end
