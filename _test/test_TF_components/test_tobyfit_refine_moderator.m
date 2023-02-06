classdef test_tobyfit_refine_moderator < TestCaseWithSave
    % Test of fitting moderator with Tobyfit
    
    properties
        w1inc
        mc
        nlist
        tolerance
        seed
        rng_state
    end
    
    methods
        function obj = test_tobyfit_refine_moderator (name)
            % Initialise object properties and pre-load test cuts for faster tests
            
            % Note: in the (hopefully) extremely rare case of needing to
            % regenerate the data, use the static method generate_data (see
            % elsewhere in this class definition)
            data_file = 'test_tobyfit_refine_moderator_data.mat';   % filename where cuts for tests are stored
            obj = obj@TestCaseWithSave(name);
            
            % Load sqw cuts
            load (data_file, 'w1inc');
            
            % Add sample and instrument information to the RbMnF3 cuts
            sample = IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.02,0.02,0.02]);
            sample.alatt = [4.2240 4.2240 4.2240];
            sample.angdeg = [90 90 90];
            w1inc=set_sample(w1inc,sample);
            w1inc=set_instrument(w1inc,@maps_instrument_obj_for_tests,'-efix',300,'S');
            
            % Initialise test object properties
            obj.w1inc = w1inc;      % Cut over purely incoherent line
            tol_sig = 0.25;     % tolerance as multiple of st. dev. of reference value
            tol_abs = 0;        % absolute tolerance
            tol_rel = 0;        % relative tolerance
            obj.tolerance = [tol_sig, tol_abs, tol_rel];
            obj.seed = 0;
            obj.mc = 2;
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
        % Fit moderator linewidth from incoherent const-E cut taken from RbMnF3
        % ---------------------------------------------------------------------------------------
        
        function obj = test_RbMnF3_incoherent_1(obj)
            
            data = obj.w1inc;

            % Get moderator pulse name and parameters
            [pulse_model, ppmod, ok] = get_mod_pulse(data);
            if ~ok
                error('test_RbMnF3_incoherent_1:invalid_argument',...
                    'Check name and parameters are all the same (within some small tolerance')
            end

            % Set moderator tauf to something else to actually test fitting
            ppmod = 0.65*ppmod;
            data = set_mod_pulse(data, pulse_model, ppmod);

            % Height, position and intrinsic FWHH for vanadium scattering
            % Note that the vanadium FWHH must be >0; typically 0.1*elastic
            % energy resolution
            amp=100; en0=0; fwhh=0.25;

            kk = tobyfit (data);
            kk = kk.set_refine_moderator (pulse_model, ppmod, [1,0,0]);
            kk = kk.set_fun (@testfunc_sqw_van, [amp,en0,fwhh], [1,1,0]);
            kk = kk.set_mc_points (obj.mc);
            kk = kk.set_options('listing', obj.nlist);

            [~, fp, ok, mess, pmodel, ppfit, psigfit] = kk.fit;
            
            assertTestWithSave (obj, fp, @is_same_fit, obj.tolerance)
            assertEqual ([ppfit, psigfit],[fp.p(4:6), fp.sig(4:6)])
            assertEqual (pulse_model, pmodel)
            
        end
        
        
    end
    
    %------------------------------------------------------------------
    methods (Static)
        function generate_data (datafile)
            % Generate data and save to file
            %
            % Use:
            %   >> test_tobyfit_refine_moderator.generate_data ('my_output_file.mat')
            %
            % Input:
            % ------
            %   datafile    Name of file to which to save cuts for future use
            %               e.g. fullfile(tempdir,'test_tobyfit_refine_moderator_data.mat')
            %               Normal practice is to write to tempdir to check contents
            %               before manually replacing the file in the repository.
            
            % sqw files from which to take cuts for setup
            % These are private to Toby's computer as of 22/1/2023
            % Long term solution needed for data source locations
            data_source = 'T:\data\RbMnF3\sqw\rbmnf3_ref_newformat.sqw';
            
            % Cuts from RbMnF3
            % ----------------
            proj.u=[1,1,0];
            proj.v=[0,0,1];
            w1inc=cut_sqw(data_source,proj,[0.3,0.5],[0,0.2],[-0.1,0.1],[-3,0.1,3]);
            
            % Save data
            % ---------
            save(datafile,'w1inc');
            disp(['Saved data for future use in ',datafile])
            
        end
    end
    
end
