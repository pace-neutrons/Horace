classdef test_tobyfit_let_resfun < TestCaseWithSave
    % Test of fitting moderator with Tobyfit
    
    properties
        w_nb_qe
        tolerance
    end
    
    methods
        function obj = test_tobyfit_let_resfun (name)
            % Initialise object properties and pre-load test cuts for faster tests

            data_file = 'test_tobyfit_let_resfun_data.mat';   % filename where cuts for tests are stored
            obj = obj@TestCaseWithSave(name);
            
            % Load sqw cuts
            load (data_file, 'w_nb_qe');
            
            % Add sample and instrument information to the Nb cut
            efix = 8.04;
            instru = let_instrument_obj_for_tests (efix, 280, 140, 20, 2, 2);
            sample = IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.012,0.012,0.04]);
            sample.alatt = [3.3000 3.3000 3.3000];
            sample.angdeg = [90 90 90];
            
            w_nb_qe=set_sample(w_nb_qe,sample);
            w_nb_qe=set_instrument(w_nb_qe,instru);

            % Initialise test object properties
            obj.w_nb_qe = w_nb_qe;
            obj.tolerance = [1e-8, 1e-8];
            
            % Required final line (see testCaseWithSave documentation)
            obj.save();
        end
        
        
        %% --------------------------------------------------------------------------------------
        % Plot various ellipsoids on plots of sqw objects
        % ---------------------------------------------------------------------------------------
        
        % Manual check on how they look is required at the moment. The automatic
        % checks are the covariance matrices from which the plots are created.
        
        function obj = test_qe (obj)
            plot(obj.w_nb_qe)
            lx 0 0.2
            lz 0 10000
            cov1 = resolution_plot (obj.w_nb_qe, [0.05,1.20; 0.15,2.80], 'curr');
            
            assertEqualToTolWithSave (obj, cov1, obj.tolerance)
        end
        
    end
    
end
