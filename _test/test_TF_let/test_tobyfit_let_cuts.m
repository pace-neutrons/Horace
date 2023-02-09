classdef test_tobyfit_let_cuts < TestCaseWithSave
    % Test of basic fitting operations with Tobyfit for LET type instrument
    
    properties
        nb_arr
        mc
        nlist
        tolerance
        seed
        rng_state
    end
    
    methods
        function obj = test_tobyfit_let_cuts (name)
            % Initialise object properties and pre-load test cuts for faster tests
            
            data_file = 'test_tobyfit_let_cuts_data.mat';   % filename where cuts for tests are stored
            obj = obj@TestCaseWithSave(name);

            % Load sqw cuts
            load (data_file, 'w1a', 'w1b');
            
            % Add instrument and sample information to the cuts
            efix = 8.04;
            instru = let_instrument_obj_for_tests (efix, 280, 140, 20, 2, 2);
            sample = IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.012,0.012,0.04]);
            sample.alatt = w1a.data.alatt;
            sample.angdeg = w1a.data.angdeg;
            
            w1a = set_instrument (w1a, instru);
            w1a = set_sample (w1a, sample);
            
            w1b = set_instrument (w1b, instru);
            w1b = set_sample (w1b, sample);
            
                
            % Initialise test object properties
            obj.nb_arr = [w1a,w1b];
            
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
        % Fit multiple datasets from Nb
        % ---------------------------------------------------------------------------------------
        
        function obj = test_fit_nb_multi_amplitude_global(obj)
            % Local foreground; constrain amplitude as global but allow
            % width to vary locally.
            
            amp=6000;    fwhh=0.2;
            
            kk = tobyfit(obj.nb_arr);
            kk = kk.set_local_foreground;
            kk = kk.set_fun(@testfunc_nb_sqw,[amp,fwhh]);
            kk = kk.set_bind({2,[2,1]});
            kk = kk.set_bfun(@testfunc_bkgd,[0,0],[1,0]);
            kk = kk.set_mc_points(obj.mc);
            kk = kk.set_options('listing',obj.nlist);
            kk = kk.set_options('fit',[1e-4,20,0.01]);
            [~,fp] = kk.fit;
            
            assertTestWithSave(obj, fp, @is_same_fit, obj.tolerance)

        end
        
    end

end
