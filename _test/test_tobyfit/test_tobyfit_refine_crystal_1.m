function test_tobyfit_refine_crystal_1 (option)
% Test Tobyfit versions refining moderator parameter for a single sqw dataset
%
% Perform tests:
%   >> test_tobyfit_refine_crystal_1    % Run the Tobyfit tests and test against stored fit
%                                       % parameters in test_tobyfit_refine_crystal_1_out.mat
%                                       % in the same folder as this file
%
%   >> test_tobyfit_refine_crystal_1 ('-save')  % Run the Tobyfit tests and save fit parameters
%                                               % to file test_tobyfit_refine_crystal_1_out.mat
%                                               % in the temporary folder (given by tempdir).
%                                               % Copy to the same folder as this file to use in
%                                               % tests.
%
%   >> test_tobyfit_refine_crystal_1 ('-notest')% Run without testing against previously stored results.
%                                               % For performing visual checks or debugging the tests!


% ----------------------------------------------------------------------------
% Setup (should only have to do in extremis - assumes data on Toby Perring's computer
%   >> test_tobyfit_refine_crystal_1 ('-setup')
%                                   % Create the sqw files that will be refined and in
%                                   % the temporary folder given by tempdir. Copy these
%                                   % files to the folder
%                                   % dir_in defined in this file to use it in the following
%                                   % tests
%
%   >> status = test_tobyfit_refine_crystal_1 ('-setup')


%% --------------------------------------------------------------------------------------
nlist = 1;  % set to 1 or 2 for listing during fit

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
        error('Invalid option')
    end
end


%% --------------------------------------------------------------------------------------
% Setup
% --------------------------------------------------------------------------------------
dir_out=tempdir;    % folder for temporary file creation

% Temporary file with simulated data to be corrected
sqw_file_res=fullfile(dir_out,'tobyfit_refine_crystal_res.sqw');            % output file for simulation in reference lattice

% Temporary file for result of correction
sqw_file_res_corr=fullfile(dir_out,'tobyfit_refine_crystal_res_corr.sqw');  % output file for correction

% Save file with simulated data to be corrected
datafile='test_tobyfit_refine_crystal_1_data.mat';      

% File to which to save results of refinement
savefile='test_tobyfit_refine_crystal_1_out.mat';   % filename where saved results are written


%% --------------------------------------------------------------------------------------
% Read or create sqw file for refinement test
% --------------------------------------------------------------------------------------

efix=45;
emode=1;
en=-0.75:0.5:0.75;
par_file=fullfile(pwd,'9cards_4_4to1.par');

% Parameters for reference lattice (i.e. what we think we have)
alatt=[5,5,5];
angdeg=[90,90,90];
u=[1,1,0];
v=[0,0,1];
psi=0:1:90;
omega=0; dpsi=2; gl=3; gs=-3;

% Parameters of the true lattice (i.e. what the lattice really is)
alatt_true=[4.75,4.75,4.75];
angdeg_true=[90,90,90];
rotvec=[1,-2,-2]*(pi/180);  % orientation of the true lattice w.r.t reference lattice

% Parameters for the blobs
amp=2;
qfwhh=0.1;                  % Spread of Bragg peaks
efwhh=1;                    % Energy width of Bragg peaks

sample=IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.04,0.03,0.02]);

if save_data
    % Create sqw file for refinement testing
    % ---------------------------------------
    % Full output file names
    urange = calc_sqw_urange (efix, emode, en(1), en(end), par_file,...
        alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
    
    % Create simulations for individual spe files
    sqw_file_res_tmp=cell(size(psi));
    disp('--------------------------------------------------------------------------')
    disp('Simulating temporary sqw files with Bragg blobs, one per psi value')
    for i=1:numel(psi)
        disp(' ')
        disp(['Creating file for orientation ',num2str(i),' of ',num2str(numel(psi))])
        
        wtmp = fake_sqw (en, par_file,'', efix, emode, alatt, angdeg,...
            u, v, psi(i), omega, dpsi, gl, gs, [10,10,10,10], urange);
        
        % Tobyfit simulation to account for resolution
        wtmp{1}=set_sample_and_inst(wtmp{1},sample,@maps_instrument_obj_for_tests,'-efix',300,'S');

        kk = tobyfit(wtmp{1});
        kk = kk.set_fun(@make_bragg_blobs,{[amp,qfwhh,efwhh],[alatt,angdeg],...
            [alatt_true,angdeg_true],rotvec});
        kk = kk.set_mc_points(10);
        wsim = kk.simulate;
        wsim = noisify(wsim,0.01);
        
        wsim=set_sample_and_inst(wsim,struct(),struct());   % get rid of sample information again
        sqw_file_res_tmp{i}=fullfile(dir_out,['dummy_tobyfit_refine_crystal_1_res_',num2str(i),'.sqw']);
        save(wsim,sqw_file_res_tmp{i});
    end
    
    % Combine simulations
    disp('--------------------------------------------------------------------------')
    write_nsqw_to_sqw(sqw_file_res_tmp,sqw_file_res);
    delete_temp_file (sqw_file_res_tmp)
    
    % Now take a cut that gets the .mat file under 100MB but still contains the Bragg peaks we'll fit
    wsim=cut_sqw(sqw_file_res,projaxes([1,1,0],[0,0,1]),[-0.5,0.02,2.5],[-1.5,0.02,1.5],...
        [-0.25,0.25],[-Inf,Inf]);
    delete_temp_file (sqw_file_res)
    
    % Save cut for future use
    datafile_full = fullfile(dir_out,datafile);
    save(datafile_full,'wsim');
    disp(['Saved data for future use in',datafile_full])
    return
    
else
    % Read in data
    data = load(datafile);          % load from .mat file
    save(data.wsim,sqw_file_res);   % save as an sqw file (se want to perform tests on sqw files, no objects
end



%% ================================================================================================
% Read test results if necessary
% --------------------------------------------------------------------------------------
if test_output
    tmp=load(savefile);
end



%% --------------------------------------------------------------------------------------
%  Refine crystal using bragg_positions
% --------------------------------------------------------------------------------------
% Test that the crystal refinement works - this is a useful test in its own right

% Fit Bragg peak positions
rlu=[1,1,0; 1,1,1; 0,0,-1; 2,2,0];
radial_cut_length=0.4; radial_bin_width=0.005; radial_thickness=0.15;
trans_cut_length=15; trans_bin_width=0.5; trans_thickness=5;
opt='Gaussian';

[rlu0,width,wcut,wpeak]=bragg_positions(sqw_file_res, rlu,...
    radial_cut_length, radial_bin_width, radial_thickness,...
    trans_cut_length, trans_bin_width, trans_thickness, opt, 'bin_relative');
% bragg_positions_view(wcut,wpeak)  % for manual checking

% Get rlu_corr from peak positions:
[rlu_corr,alatt_fit,angdeg_fit,rotmat_fit,distance,rotangle] = ...
    refine_crystal(rlu0,alatt,angdeg,rlu,'fix_angdeg','fix_alatt_ratio');

if test_output
    disp('Comparing with stored fit')
    if any(abs(rlu_corr(:)-tmp.rlu_corr(:))>0.004)
        error('refine_crystal orientation refinement and stored results are not the same')
    end
end

% Test that the rotation vector is good, and the lattice parameters too:
rotvec_fit=rotmat_to_rotvec2(rotmat_fit);
if ~equal_to_relerr(alatt_fit,alatt_true,0.001) || ~equal_to_relerr(rotvec_fit,rotvec,0.10)
    error('Problem in refinement of crystal orientation and lattice parameters')
end

% Reorient the lattice in a copy of the file, and test that the new sqw file is correct
copyfile(sqw_file_res,sqw_file_res_corr)
change_crystal_sqw(sqw_file_res_corr,rlu_corr)
[rlu0,width,wcut,wpeak]=bragg_positions(read_sqw(sqw_file_res_corr), rlu,...
    radial_cut_length, radial_bin_width, radial_thickness,...
    trans_cut_length, trans_bin_width, trans_thickness, opt, 'bin_relative');
% bragg_positions_view(wcut,wpeak)  % for manual checking

if max(abs(rlu0(:)-rlu(:)))>0.005
    error('Problem in refinement of crystal orientation and lattice parameters')
else    % delete file
    delete_temp_file (sqw_file_res_corr)
end


%% --------------------------------------------------------------------------------------
%  Refine crystal using Tobyfit
% --------------------------------------------------------------------------------------

proj.u=[1,1,0];
proj.v=[0,0,1];

w110_r=cut_sqw(sqw_file_res,proj,[0.8,0.01,1.2],[-0.2,0.2],[-0.15,0.15],[-Inf,Inf]);
w110_t=cut_sqw(sqw_file_res,proj,[0.85,1.15],[-0.2,0.01,0.2],[-0.15,0.15],[-Inf,Inf]);
w110_v=cut_sqw(sqw_file_res,proj,[0.85,1.15],[-0.2,0.2],[-0.15,0.01,0.2],[-Inf,Inf]);

w00m1_r=cut_sqw(sqw_file_res,proj,[-0.15,0.15],   [-1.3,0.01,-0.7],[-0.15,0.15],   [-Inf,Inf]);
w00m1_t=cut_sqw(sqw_file_res,proj,[-0.2,0.01,0.2],[-1.2,-0.8],     [-0.15,0.15],   [-Inf,Inf]);
w00m1_v=cut_sqw(sqw_file_res,proj,[-0.15,0.15],   [-1.2,-0.8],     [-0.2,0.01,0.2],[-Inf,Inf]);

w110_r=set_sample_and_inst(w110_r,sample,@maps_instrument_obj_for_tests,'-efix',300,'S');
w110_t=set_sample_and_inst(w110_t,sample,@maps_instrument_obj_for_tests,'-efix',300,'S');
w110_v=set_sample_and_inst(w110_v,sample,@maps_instrument_obj_for_tests,'-efix',300,'S');

w00m1_r=set_sample_and_inst(w00m1_r,sample,@maps_instrument_obj_for_tests,'-efix',300,'S');
w00m1_t=set_sample_and_inst(w00m1_t,sample,@maps_instrument_obj_for_tests,'-efix',300,'S');
w00m1_v=set_sample_and_inst(w00m1_v,sample,@maps_instrument_obj_for_tests,'-efix',300,'S');

w=[w110_r,w110_t,w110_v;w00m1_r,w00m1_t,w00m1_v];

mc = 2;

% Fit a global function
% ---------------------
kk = tobyfit (w);
kk = kk.set_refine_crystal ('fix_angdeg','fix_alatt_ratio');
kk = kk.set_mc_points (mc);
kk = kk.set_fun (@make_bragg_blobs,{[amp,qfwhh,efwhh],[alatt,angdeg]},[1,1,0]);
kk = kk.set_options('list',nlist);
disp('Now fitting. This may take some time (around a minute)...')
[w_tf_a,fitpar_tf_a,ok,mess,rlu_corr_tf_a] = kk.fit;

if ~ok
    disp(mess)
end
if any(abs(rlu_corr_tf_a(:)-rlu_corr(:))>0.004)
    error('  1 of 2: Bragg peak crystal refinement and Tobyfit crystal refinement are not the same')
end

if test_output
    disp('Comparing with stored fit')
    if any(abs(rlu_corr_tf_a(:)-tmp.rlu_corr_tf_a(:))>0.004)
        error('  1 of 2: Tobyfit crystal refinement and stored results are not the same')
    end
end


% Fit local foreground functions (independent widths)
% ---------------------------------------------------
kk = tobyfit (w);
kk = kk.set_refine_crystal ('fix_angdeg','fix_alatt_ratio');
kk = kk.set_mc_points (mc);
kk = kk.set_local_foreground(true);
kk = kk.set_fun (@make_bragg_blobs,{{[amp,qfwhh,efwhh],[alatt,angdeg]}},[1,1,0]);
kk = kk.set_options('list',nlist);
disp('Now fitting. This may take some time (around a minute)...')
[w_tf_b,fitpar_tf_b,ok,mess,rlu_corr_tf_b] = kk.fit;

if ~ok
    disp(mess)
end
if any(abs(rlu_corr_tf_b(:)-rlu_corr(:))>0.004)
    error('  2 of 2: Bragg peak crystal refinement and Tobyfit crystal refinement are not the same')
end

if test_output
    disp('Comparing with stored fit')
    if any(abs(rlu_corr_tf_b(:)-tmp.rlu_corr_tf_b(:))>0.004)
        error('  2 of 2: Tobyfit crystal refinement and stored results are not the same')
    end
end


% %% --------------------------------------------------------------------------------------
% % Collect results together as a structure
% % ---------------------------------------------------------------------------------------
% 
% res.rlu_corr = rlu_corr;
% res.rotmat_fit = rotmat_fit;
% 
% res.w = w;
% 
% res.w_tf_a = w_tf_a;
% res.fitpar_tf_a = fitpar_tf_a;
% res.rlu_corr_tf_a = rlu_corr_tf_a;
% 
% res.w_tf_b = w_tf_b;
% res.fitpar_tf_b = fitpar_tf_b;
% res.rlu_corr_tf_b = rlu_corr_tf_b;



%% --------------------------------------------------------------------------------------
% Save fit parameter output if requested
% ---------------------------------------------------------------------------------------
if save_output
    save(fullfile(tempdir,savefile),'rlu_corr','rlu_corr_tf_a','rlu_corr_tf_b');
end




%========================================================================================
function delete_temp_file (flname)
% Delete file or cell array of files
if ~iscell(flname), flname={flname}; end
for i=1:numel(flname)
    try
        delete(flname{i})
    catch
        disp(['Unable to delete temporary file: ',flname{i}])
    end
end
