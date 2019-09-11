function test_tobyfit_mosaic (option, version)
% Test mosaic spread in Tobyfit
%
% Perform tests:
%   >> test_tobyfit_mosaic          % Run the Tobyfit tests and test against stored fit
%                                   % parameters in test_tobyfit_mosaic_out.mat in the same
%                                   % folder as this file
%
%   >> test_tobyfit_mosaic ('-save')% Run the Tobyfit tests and save fit parameters
%                                   % to file test_tobyfit_mosaic_out.mat
%                                   % in the temporary folder (given by tempdir)
%                                   % Copy to the same folder as this file to use in
%                                   % tests.
%
%   >> test_tobyfit_mosaic ('-notest')% Run without testing against previously stored results.
%                                   % For performing visual checks or debugging the tests!
%
%
% Do any of the above, run with the legacy version of Tobyfit:
%   >> test_tobyfit_mosaic (...,'-legacy')


% ----------------------------------------------------------------------------
% Setup (should only have to do in extremis - assumes data on Toby Perring's computer
%   >> test_tobyfit_mosaic ('-setup') % Create the cuts that will be fitted and save in
%                                   % test_tobyfit_mosaic_data.mat in the temporary folder
%                                   % given by tempdir. Copy this file to the same folder
%                                   % that holds this .m file to use it in the following
%                                   % tests
%   >> status = test_tobyfit_mosaic ('-setup')


%% --------------------------------------------------------------------------------------

% ***************************************
%    Need to complete this test
% ***************************************
% Temporary dummy test
return
% ***************************************
% ***************************************

nlist = 0;  % set to 1 or 2 for listing during fit

% Determine whether or not to save output
save_data = false;
save_output = false;
test_output = true;
legacy = false;

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


%% --------------------------------------------------------------------------------------
% Setup
%data_source='E:\data\aaa_Horace\Fe_ei787.sqw';  % sqw file from which to take cuts for setup
data_source='D:\data\Fe\sqw_Toby\Fe_ei787.sqw';  % sqw file from which to take cuts for setup

datafile='test_tobyfit_mosaic_data.mat';   % filename where saved results are written
savefile='test_tobyfit_mosaic_out.mat';   % filename where saved results are written



%% --------------------------------------------------------------------------------------
% Create cuts to save as input data
% --------------------------------------------------------------------------------------
if save_data
    % Area cuts about 200, 1-10 and 020
    proj_100 = projaxes([1,0,0],[0,1,0]);
    w2_200=cut_sqw(data_source,proj_100,[1.95,2.05],[-0.3,0.02,0.3],[-0.3,0.02,0.3],[-10,10]);
    
    proj_010 = projaxes([0,1,0],[-1,0,0]);
    w2_020=cut_sqw(data_source,proj_010,[1.95,2.05],[-0.3,0.02,0.3],[-0.3,0.02,0.3],[-10,10]);
    
    proj_1m10 = projaxes([1,-1,0],[1,1,0]);
    w2_1m10=cut_sqw(data_source,proj_1m10,[0.965,1.035],[-0.2,0.015,0.2],[-0.3,0.02,0.3],[-10,10]);
    
    % Now save to file for future use
    datafile_full = fullfile(tempdir,datafile);
    save(datafile_full,'w2_200','w2_020','w2_1m10');
    disp(['Saved data for future use in',datafile_full])
    return
    
else
    % Read in data
    load(datafile);
end



%% --------------------------------------------------------------------------------------
% Evaluate sqw and Tobyfit simulation for single cut
% --------------------------------------------------------------------------------------
% Add instrument and sample information to cuts
sample=IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.04,0.03,0.02],[6,0,4]);

w2_200=set_sample_and_inst(w2_200,sample,@maps_instrument_obj_for_tests,'-efix',600,'S');
w2_020=set_sample_and_inst(w2_020,sample,@maps_instrument_obj_for_tests,'-efix',600,'S');
w2_1m10=set_sample_and_inst(w2_1m10,sample,@maps_instrument_obj_for_tests,'-efix',600,'S');


% Lattice parameters
alatt = w2_020.header{1}.alatt;
angdeg = w2_020.header{1}.angdeg;

% Model parameters for Bragg blobs
amp=1;  qfwhh=0.1;   efwhh=1;

% Evaluate S(Q,w) model
w2_200_eval=sqw_eval(w2_200,@make_bragg_blobs,{[amp,qfwhh,efwhh],[alatt,angdeg]});
w2_020_eval=sqw_eval(w2_020,@make_bragg_blobs,{[amp,qfwhh,efwhh],[alatt,angdeg]});
w2_1m10_eval=sqw_eval(w2_1m10,@make_bragg_blobs,{[amp,qfwhh,efwhh],[alatt,angdeg]});

% Tobyfit simulation
kk = tobyfit(w2_200);
kk = kk.set_fun(@make_bragg_blobs,{[amp,qfwhh,efwhh],[alatt,angdeg]});
kk = kk.set_mc_points(100);
kk = kk.set_mc_contributions('none');
w2_200_sim_nores = kk.simulate;
kk = kk.set_mc_contributions('mosaic');
w2_200_sim_mosaic = kk.simulate;

kk = tobyfit(w2_020);
kk = kk.set_fun(@make_bragg_blobs,{[amp,qfwhh,efwhh],[alatt,angdeg]});
kk = kk.set_mc_points(100);
kk = kk.set_mc_contributions('none');
w2_020_sim_nores = kk.simulate;
kk = kk.set_mc_contributions('mosaic');
w2_020_sim_mosaic = kk.simulate;

kk = tobyfit(w2_1m10);
kk = kk.set_fun(@make_bragg_blobs,{[amp,qfwhh,efwhh],[alatt,angdeg]});
kk = kk.set_mc_points(100);
kk = kk.set_mc_contributions('none');
w2_1m10_sim_nores = kk.simulate;
kk = kk.set_mc_contributions('mosaic');
w2_1m10_sim_mosaic = kk.simulate;




%% --------------------------------------------------------------------------------------
% Evaluate sqw and Tobyfit simulation for single cut with LET instrument
% --------------------------------------------------------------------------------------
% The idea is to test the validity of the code, not a realistc instrumnet! 
% Get fudged parameters to give a reasonable resolution

% Add instrumnet and sample information to cuts
sample=IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.04,0.03,0.02],[6,0,4]);

instru = let_instrument_obj_for_tests (80, 280, 140, 20, 2, 2);
instru.shaping_chopper = IX_doubledisk_chopper(2,300,1,0.02);
instru.mono_chopper = IX_doubledisk_chopper(10,300,1,0.02);
instru.energy=787;

w2_200=set_sample_and_inst(w2_200,sample,instru);
w2_020=set_sample_and_inst(w2_020,sample,instru);
w2_1m10=set_sample_and_inst(w2_1m10,sample,instru);


% Lattice parameters
alatt = w2_020.header{1}.alatt;
angdeg = w2_020.header{1}.angdeg;

% Model parameters for Bragg blobs
amp=1;  qfwhh=0.1;   efwhh=1;

% Evaluate S(Q,w) model
w2_200_eval=sqw_eval(w2_200,@make_bragg_blobs,{[amp,qfwhh,efwhh],[alatt,angdeg]});
w2_020_eval=sqw_eval(w2_020,@make_bragg_blobs,{[amp,qfwhh,efwhh],[alatt,angdeg]});
w2_1m10_eval=sqw_eval(w2_1m10,@make_bragg_blobs,{[amp,qfwhh,efwhh],[alatt,angdeg]});

% Tobyfit simulation
kk = tobyfit(w2_200);
kk = kk.set_fun(@make_bragg_blobs,{[amp,qfwhh,efwhh],[alatt,angdeg]});
kk = kk.set_mc_points(100);
kk = kk.set_mc_contributions('none');
w2_200_sim_nores = kk.simulate;
kk = kk.set_mc_contributions('mosaic');
w2_200_sim_mosaic = kk.simulate;

kk = tobyfit(w2_020);
kk = kk.set_fun(@make_bragg_blobs,{[amp,qfwhh,efwhh],[alatt,angdeg]});
kk = kk.set_mc_points(100);
kk = kk.set_mc_contributions('none');
w2_020_sim_nores = kk.simulate;
kk = kk.set_mc_contributions('mosaic');
w2_020_sim_mosaic = kk.simulate;

kk = tobyfit(w2_1m10);
kk = kk.set_fun(@make_bragg_blobs,{[amp,qfwhh,efwhh],[alatt,angdeg]});
kk = kk.set_mc_points(100);
kk = kk.set_mc_contributions('none');
w2_1m10_sim_nores = kk.simulate;
kk = kk.set_mc_contributions('mosaic');
w2_1m10_sim_mosaic = kk.simulate;



%% --------------------------------------------------------------------------------------
% Save fit parameter output if requested
% ---------------------------------------------------------------------------------------
% if save_output
%     save(fullfile(tempdir,savefile),...
%         'fp110a1','fp110a2','fp110a3','fp110a4','fp110arr1','fp110arr2');
% end


