classdef test_tobyfit_let_components < TestCaseWithSave
    % Test of basic fitting operations with Tobyfit
    
    properties
        efix
        wref
        
        tol_hist_chisqr
        tol_hist_fwhh
        
        mc
        nlist
        tol_fwhh
        seed
        rng_state
    end
    
    methods
        function obj = test_tobyfit_let_components (name)
            % Initialise object properties and pre-load test cuts for faster tests
            
            % Note: in the (hopefully) extremely rare case of needing to
            % regenerate the data, use the static method generate_data (see
            % elsewhere in this class definition)
            data_file = 'test_tobyfit_let_components_data.mat';   % filename where cuts for tests are stored
            obj = obj@TestCaseWithSave(name);
            
            % Load sqw cuts
            load (data_file, 'w1');
            
            % Add instrument and sample information to the cuts
            % mod FWHH=99.37us, shape_chop FWHH=162.4us
            efix = w1.experiment_info.expdata.efix;
            instru = let_instrument_obj_for_tests (efix, 280, 140, 20, 2, 2);
            samp = IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);
            
            w1 = set_instrument (w1, instru);
            w1 = set_sample (w1, samp);
            
            % Simulate with vanadium lineshape
            wref = sqw_eval(w1,@van_sqw,[10,0,0.05]);   % 50 ueV fwhh; peak_cwhh gives 54
            wref = noisify(wref,1);     % add error bars
            
            % Initialise test object properties
            obj.efix = efix;
            obj.wref = wref;
            
            % Sampling of mod-shape-mono time pulse
            obj.tol_hist_chisqr = 0.25;     % Absolute chisqr tolerance. The primary test
            obj.tol_hist_fwhh = [0,0.08];   % relaxed to allow for low statistics sampling
            
            % Simulation of elastic line for different resolution contributions
            obj.tol_fwhh = [0,0.03];
            
            obj.seed = 0;
            obj.mc = 3;
            obj.nlist = 0;
            
            % Required final line (see testCaseWithSave documentation)
            obj.save();
        end
        
        function obj = setUp(obj)
            % Save current rng state and force random seed and method
            obj.rng_state = rng(obj.seed, 'twister');
            warning('off', 'HERBERT:mask_data_for_fit:bad_points')
        end
        
        function obj = tearDown(obj)
            % Undo rng state
            rng(obj.rng_state);
            warning('on', 'HERBERT:mask_data_for_fit:bad_points')
        end
        
        
        %% --------------------------------------------------------------------------------------
        % Simulate mod-shape-mono pulse shape
        % --------------------------------------------------------------------------------------
        function obj = test_fit_modshapemono_mod_narrower(obj)
            % mod FWHH=99.37us, shape_chop FWHH=66.48us
            %
            % Will have pulse determined by moderator i.e. the moderator contribution
            % to the pulse is just slightly narrower than the shaping chopper.
            % This causes a branch to be called in the mod_shape_chop code that
            % follows a different algorithm to that for the case where the
            % shaping chopper is dominant.
            
            instru_mod = let_instrument_obj_for_tests (obj.efix, 280, 140, 20, 2, 2);
            instru_mod.shaping_chopper.frequency = 171;
            wtmp = set_instrument(obj.wref, instru_mod);
            
            % If saving as reference histogram for later tests, create higher
            % statistics histogram starting from different seed
            whist = get_mod_shape_mono_histogram (wtmp, obj.save_output);
            
            assertTestWithSave (obj, whist, @IX_dataset_1d_same,...
                obj.tol_hist_chisqr, 'chisqr', 'rebin', 'norm','nozeros')
            
            % Random sampling gives unreliable FWHH - turn test off
            %{
            [~,~,fwhh] = peak_cwhh (whist);
            assertEqualToTolWithSave(obj, fwhh, obj.tol_hist_fwhh)
            %}
        end
        
        function obj = test_fit_modshapemono_shape_narrower(obj)
            % mod FWHH=99.37us, shape_chop FWHH=66.09us
            %
            % Will have pulse determined by shaping chopper i.e. the moderator
            % contribution to the pulse is just slightly wider than the shaping chopper.
            % This causes a branch to be called in the mod_shape_chop code that
            % follows a different algorithm to that for the case where the
            % shaping chopper is dominant.
            %
            % Compare test_fit_modshapemono_mod_narrower. The pulseshape should
            % be almost identical, but a different branch is followed in the
            % sampling algorithm for mon_shape_mono
            
            instru_shape = let_instrument_obj_for_tests (obj.efix, 280, 140, 20, 2, 2);
            instru_shape.shaping_chopper.frequency = 172;
            wtmp = set_instrument(obj.wref, instru_shape);
            
            % If saving as reference histogram for later tests, create higher
            % statistics histogram starting from different seed
            whist = get_mod_shape_mono_histogram (wtmp, obj.save_output);
            
            assertTestWithSave (obj, whist, @IX_dataset_1d_same,...
                obj.tol_hist_chisqr, 'chisqr', 'rebin', 'norm','nozeros')
            
            % Random sampling gives unreliable FWHH - turn test off
            %{
            [~,~,fwhh] = peak_cwhh (whist);
            assertEqualToTolWithSave(obj, fwhh, obj.tol_hist_fwhh)
            %}
        end
        
        
        function obj = test_fit_modshapemono_mod_only(obj)
            % mod FWHH=99.37us, shape_chop FWHH=11368us
            %
            % Shaping chopper is irrelevant, as its pulse is effectively infinitely
            % broad. Tests another limiting case.
            
            instru_mod_only = let_instrument_obj_for_tests (obj.efix, 280, 140, 20, 2, 2);
            instru_mod_only.shaping_chopper.frequency = 1;
            wtmp = set_instrument(obj.wref, instru_mod_only);
            
            % If saving as reference histogram for later tests, create higher
            % statistics histogram starting from different seed
            whist = get_mod_shape_mono_histogram (wtmp, obj.save_output);
            
            assertTestWithSave (obj, whist, @IX_dataset_1d_same,...
                obj.tol_hist_chisqr, 'chisqr', 'rebin', 'norm','nozeros')
            
            % Random sampling gives unreliable FWHH - turn test off
            %{
            [~,~,fwhh] = peak_cwhh (whist);
            assertEqualToTolWithSave(obj, fwhh, obj.tol_hist_fwhh)
            %}
        end
        
        
        function obj = test_fit_modshapemono_shape_only(obj)
            % mod FWHH=33947us, shape_chop FWHH=66.48us
            %
            % Moderator is irrelevant, as its pulse is effectively infinitely
            % broad. Tests another limiting case.
            
            instru_shape_only = let_instrument_obj_for_tests (obj.efix, 280, 140, 20, 2, 2);
            instru_shape_only.moderator.pp(1) = 10000;
            instru_shape_only.shaping_chopper.frequency = 171;
            wtmp = set_instrument(obj.wref, instru_shape_only);
            
            % If saving as reference histogram for later tests, create higher
            % statistics histogram starting from different seed
            whist = get_mod_shape_mono_histogram (wtmp, obj.save_output);
            
            assertTestWithSave (obj, whist, @IX_dataset_1d_same,...
                obj.tol_hist_chisqr, 'chisqr', 'rebin', 'norm','nozeros')
            
            % Random sampling gives unreliable FWHH - turn test off
            %{
            [~,~,fwhh] = peak_cwhh (whist);
            assertEqualToTolWithSave(obj, fwhh, obj.tol_hist_fwhh)
            %}
        end
        
        
        %% --------------------------------------------------------------------------------------
        % Test the various contributions to the resolution function
        % --------------------------------------------------------------------------------------
        
        function test_all_contributions (obj)
            % All contributions: fwhh = 204 ueV
            wsim = simulate_tobyfit_let_components (obj, 0, 'all');
            
            w = IX_dataset_1d (wsim);
            [~,~,fwhh] = peak_cwhh (w);
            
            assertEqualToTolWithSave (obj, fwhh, obj.tol_fwhh)
        end
        
        
        function test_no_contributions (obj)
            % No contributions: fwhh = 54 ueV
            wsim = simulate_tobyfit_let_components (obj, 0, 'none');
            
            w = IX_dataset_1d (wsim);
            [~,~,fwhh] = peak_cwhh (w);
            
            assertEqualToTolWithSave (obj, fwhh, obj.tol_fwhh)
        end
        
        
        function test_mod_shape (obj)
            % Moderator & shape chopper only: fwhh = 123 ueV
            wsim = simulate_tobyfit_let_components (obj, 0, 'moderator','shape_chopper');
            
            w = IX_dataset_1d (wsim);
            [~,~,fwhh] = peak_cwhh (w);
            
            assertEqualToTolWithSave (obj, fwhh, obj.tol_fwhh)
        end
        
        
        function test_mono (obj)
            % Mono chopper only: fwhh = 169 ueV
            wsim = simulate_tobyfit_let_components (obj, 0, 'mono_chopper');
            
            w = IX_dataset_1d (wsim);
            [~,~,fwhh] = peak_cwhh (w);
            
            assertEqualToTolWithSave (obj, fwhh, obj.tol_fwhh)
        end
        
        
        function test_mod_shape_mono (obj)
            % Moderator & both chopper only: fwhh = 192 ueV
            wsim = simulate_tobyfit_let_components (obj, 0,...
                'moderator','shape_chopper','mono_chopper');
            
            w = IX_dataset_1d (wsim);
            [~,~,fwhh] = peak_cwhh (w);
            
            assertEqualToTolWithSave (obj, fwhh, obj.tol_fwhh)
        end
        
        
        function test_horiz_vert (obj)
            % Divergence only: fwhh = 54 ueV
            wsim = simulate_tobyfit_let_components (obj, 0, 'horiz','vert');
            
            w = IX_dataset_1d (wsim);
            [~,~,fwhh] = peak_cwhh (w);
            
            assertEqualToTolWithSave (obj, fwhh, obj.tol_fwhh)
        end
        
        
        function test_sample (obj)
            % Sample only: fwhh = 77 ueV
            wsim = simulate_tobyfit_let_components (obj, 0, 'sample');
            
            w = IX_dataset_1d (wsim);
            [~,~,fwhh] = peak_cwhh (w);
            
            assertEqualToTolWithSave (obj, fwhh, obj.tol_fwhh)
        end
        
        
        function test_det_depth (obj)
            % Detector depth only: fwhh = 67 ueV
            wsim = simulate_tobyfit_let_components (obj, 0, 'detector_depth');
            
            w = IX_dataset_1d (wsim);
            [~,~,fwhh] = peak_cwhh (w);
            
            assertEqualToTolWithSave (obj, fwhh, obj.tol_fwhh)
        end
        
        
        function test_det_area (obj)
            % Detector area only: fwhh = 54 ueV
            wsim = simulate_tobyfit_let_components (obj, 0, 'detector_area');
            
            w = IX_dataset_1d (wsim);
            [~,~,fwhh] = peak_cwhh (w);
            
            assertEqualToTolWithSave (obj, fwhh, obj.tol_fwhh)
        end
        
        
        function test_energy_bin (obj)
            % Energy bins only: fwhh = 56 ueV
            wsim = simulate_tobyfit_let_components (obj, 0, 'energy_bin');
            
            w = IX_dataset_1d (wsim);
            [~,~,fwhh] = peak_cwhh (w);
            
            assertEqualToTolWithSave (obj, fwhh, obj.tol_fwhh)
        end
        
        function test_noshape (obj)
            % No shaping chopper: fwhh = 209 ueV
            % All constributions give a width of 204 ueV. Paradoxically removing either
            % the shaping chopper or moderator results in a greater width. This is
            % because the pulse width at the shaping chopper is  made bigger
            wsim = simulate_tobyfit_let_components (obj, 1, 'noshape');
            
            w = IX_dataset_1d (wsim);
            [~,~,fwhh] = peak_cwhh (w);
            
            assertEqualToTolWithSave (obj, fwhh, obj.tol_fwhh)
        end
        
        
        function test_no_mod (obj)
            % No moderator pulse: fwhh = 347 ueV
            % All constributions give a width of 204 ueV. Paradoxically removing either
            % the shaping chopper or moderator results in a greater width. This is
            % because the pulse width at the shaping chopper is  made bigger
            wsim = simulate_tobyfit_let_components (obj, 1, 'nomod');
            
            w = IX_dataset_1d (wsim);
            [~,~,fwhh] = peak_cwhh (w);
            
            assertEqualToTolWithSave (obj, fwhh, obj.tol_fwhh)
        end
        
    end
    
    
    %------------------------------------------------------------------
    methods (Static)
        function generate_data (datafile)
            % Generate data and save to file
            %
            % Use:
            %   >> test_tobyfit_let_components.generate_data ('my_output_file.mat')
            %
            % Input:
            % ------
            %   datafile    Name of file to which to save cuts for future use
            %               e.g. fullfile(tempdir,'test_tobyfit_let_components_data.mat')
            %               Normal practice is to write to tempdir to check contents
            %               before manually replacing the file in the repository.
            
            % Data for creation of dummy_sqw data
            % -----------------------------------
            efix=8;
            emode=1;
            en0=-3:0.02:7;
            par_file=fullfile(pwd,'LET_one2one_153.par');
            
            % Parameters for reference lattice (i.e. what we think we have)
            alatt=[5,5,5];
            angdeg=[90,90,90];
            u=[1,1,0];
            v=[0,0,1];
            psi0=180;
            omega=0; dpsi=0; gl=0; gs=0;
            
            % Create sqw file for refinement testing
            % ---------------------------------------
            sqw_file = fullfile(tmp_dir,'test_tobyfit_let_components.sqw');
            dummy_sqw (en0, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi0, omega, dpsi, gl, gs);
            
            % Create cut
            % ----------
            proj.u = [1,1,0];
            proj.v = [0,0,1];
            w1 = cut_sqw (sqw_file, proj, [-0.5,0], [0.5,1], [-0.2,0.2], [-3.01,0.02,7.01]);
            
            % Save data
            % ---------
            save(datafile, 'w1');
            disp(['Saved data for future use in ',datafile])
            
        end
    end
    
end


% -----------------------------------------------------------------------------------------
function [whist, wsim] = get_mod_shape_mono_histogram (wtmp, reference_data)
% Use the debugtools utility to call a line in tobyfit_DGdisk_resconv that
% will create a histogram of the distribution from the moderator-chopper
% monochromating combination. This line is a call to utility function
% debugtools, which writes the histogram to file for reading in this function.

cleanup = onCleanup(@()debugtools('off'));

debugtools('on')    % activate the line of code in tobyfit_DGdisk_resconv

kk = tobyfit (wtmp);
if reference_data
    % Change the random see for producing the reference random sample from
    % the pulse shape, as we want to make sure that we have a random histogram
    % that is not just an identical copy of that produced by the test run
    rng(5163224, 'twister');
else
    % Keep a limited portion of the data to reduce the number of samples
    % from the mod-shape-mono pulse
    % (This is the only way to reduce the number of samples in this case,
    % as a new debug file created for each increment of mc)
    kk = kk.set_mask('keep',[-0.5,0.5]);    % broad enough to cover the range of the elastic peak
end
kk = kk.set_fun(@van_sqw,[10,0,0.05]);
kk = kk.set_mc_points(1);   % Only mc = 1, as a new debug file created for each increment of mc
wsim = kk.simulate;

tmp = load(fullfile(tmp_dir,'histogram.mat'));
whist = tmp.w;

debugtools('off')   % deactivate the debug line

end

% -----------------------------------------------------------------------------------------
function wsim = simulate_tobyfit_let_components (obj, init_state, varargin)
% Standard Tobyfit setup for simulating the elastic line
%
%   >> kk = setup_test_tobyfit_let_components (obj, c1, c2, ...)
%
% Input:
% ------
%   obj             Test object
%
%   init_state      If init_state = 0: initial state is no contributions
%                   If init_state = 1: initial state is all contributions
%
%
%   c1, c2, ...     The element(s) that will be contributing. Each must be of the
%                   valid options to the Tobyfit set_mc_contributions
%                   Default: no contributions i.e. no resolution broadening
%
% Output:
% -------
%   wsim            Tobyfit simulation
%
% EXAMPLES
%   >> kk = setup_test_tobyfit_let_components (obj, 0, 'all')
%   >> kk = setup_test_tobyfit_let_components (obj, 0, 'none')
%   >> kk = setup_test_tobyfit_let_components (obj, 0, 'moderator','shape_chopper','mono_chopper');
%   >> kk = setup_test_tobyfit_let_components (obj, 1, 'nomod')

kk = tobyfit (obj.wref);
kk = kk.set_mask('keep',[-0.5,0.5]);    % broad enough for any of the simulations
kk = kk.set_fun (@van_sqw,[10,0,0.05]);

if ~obj.save_output
    kk = kk.set_mc_points (obj.mc);
else
    rng(5163224, 'twister');            % different seed than the test data
    kk = kk.set_mc_points (5*obj.mc);   % higher stats if going to save
end

if logical(init_state)==true
    kk = kk.set_mc_contributions ('all');   % Initialise with all contributions
else
    kk = kk.set_mc_contributions ('none');  % Get rid of all
end
kk = kk.set_mc_contributions (varargin{:});

wsim = kk.simulate;

end
