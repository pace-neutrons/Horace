classdef test_IX_detector_bank_1 < TestCaseWithSave
    % Test the calculation of quantities for IX_detector_bank object
    properties
        dets
        id
        x2
        phi
        azim
        rotvec
    end
    
    methods
        %--------------------------------------------------------------------------
        function obj = test_IX_detector_bank_1 (name)
            obj@TestCaseWithSave(name);
            
            % Arrays for construction of detectors
            % Note: have varying paths w.r.t. detector coordinate frame
            dia(1) = 0.0254;  height(1) = 0.015; wall(1) = 6.35e-4; atms(1) = 10;
            dia(2) = 0.0300;  height(2) = 0.025; wall(2) = 10.0e-4; atms(2) = 6;
            dia(3) = 0.0400;  height(3) = 0.035; wall(3) = 15.0e-4; atms(3) = 4;
            dia(4) = 0.0400;  height(4) = 0.035; wall(4) = 15.0e-4; atms(4) = 7;
            dia(5) = 0.0400;  height(5) = 0.035; wall(5) = 15.0e-4; atms(5) = 4; % same as 3rd det
            obj.dets = IX_det_He3tube (dia, height, wall, atms);
            
            obj.id = [10, 20, 30, 40, 50];
            obj.x2 = [2.1, 2.2, 2.3, 2.4, 2.5];
            obj.phi = [10, 30, 50, 70, 90];
            obj.azim = [0, 11, 22, 33, 44];
            obj.rotvec = zeros(3,5);
            obj.rotvec(:,5) = [20,45,15]';  % rotate c. 45 degrees from Debye Scherrer
            
            obj.save()
        end
        
        %--------------------------------------------------------------------------
        function test_constructor_1 (obj)

            bank = IX_detector_bank (obj.id, obj.x2, obj.phi, obj.azim, obj.dets);
            assertEqual(bank.id, obj.id(:));
            assertEqual(bank.x2, obj.x2(:));
            assertEqual(bank.phi, obj.phi(:));
            assertEqual(bank.azim, obj.azim(:));
            assertEqual(bank.det, obj.dets(:));
        end
        
        %--------------------------------------------------------------------------
        function test_constructor_2 (obj)

            bank = IX_detector_bank (obj.id, obj.x2, obj.phi, obj.azim, obj.dets, ...
                'rotvec', obj.rotvec);
            assertEqual(bank.id, obj.id(:));
            assertEqual(bank.x2, obj.x2(:));
            assertEqual(bank.phi, obj.phi(:));
            assertEqual(bank.azim, obj.azim(:));
            assertEqual(bank.det, obj.dets(:));
        end
        
        %--------------------------------------------------------------------------
        function test_effic_1 (obj)
            % Test efficiency calculation
            bank = IX_detector_bank (obj.id, obj.x2, obj.phi, obj.azim, obj.dets, ...
                'rotvec', obj.rotvec);
            wvec = 10;
            
            % Calculate for detector array directly
            ind = [1,2,3,4,5];
            paths = squeeze(bank.dmat(1,:,ind));     % extract paths from orientation matrices
            effs = effic (obj.dets, ind, paths, wvec);
            
            % Calculate from IX_detector_bank
            eff_array = bank.effic (wvec);
            
            assertEqualToTol (effs, eff_array, 'tol',[1e-13,1e-13])
            assertEqualToTolWithSave (obj, eff_array, 'tol',[1e-13,1e-13])
        end
        
        %--------------------------------------------------------------------------
        function test_effic_2 (obj)
            % Test efficiency calculation, with explicit passing of index
            % array
            bank = IX_detector_bank (obj.id, obj.x2, obj.phi, obj.azim, obj.dets, ...
                'rotvec', obj.rotvec);
            wvec = 10;
            
            % Calculate for detector array
            ind = [1,2,3,4,5];
            paths = squeeze(bank.dmat(1,:,ind));     % extract paths from orientation matrices
            effs = effic (obj.dets, ind, paths, wvec);
            
            % Calculate for IX_detector_bank with explicit ind
            eff_array = bank.effic (ind, wvec);
            
            assertEqualToTol (effs, eff_array, 'tol',[1e-13,1e-13])
            assertEqualToTolWithSave (obj, eff_array, 'tol',[1e-13,1e-13])
        end
        
        %--------------------------------------------------------------------------
        function test_effic_3 (obj)
            % Test efficiency calculation, with explicit passing of index
            % array with limited selection of possible values of ind
            bank = IX_detector_bank (obj.id, obj.x2, obj.phi, obj.azim, obj.dets, ...
                'rotvec', obj.rotvec);
            wvec = 10;
            
            % Calculate for detector array
            ind = [5,3];
            paths = squeeze(bank.dmat(1,:,ind));     % extract paths from orientation matrices
            effs = effic (obj.dets, ind, paths, wvec);
            
            % Calculate for IX_detector_bank with explicit ind
            eff_array = bank.effic(ind, wvec);
            
            assertEqualToTol (effs, eff_array, 'tol',[1e-13,1e-13])
            assertEqualToTolWithSave (obj, eff_array, 'tol',[1e-13,1e-13])
        end
        
        %--------------------------------------------------------------------------
        function test_effic_4 (obj)
            % Test efficiency calculation for subset of dets and with
            % different wavlengths
            % Make ind and wvec matrices for good measure!
            bank = IX_detector_bank (obj.id, obj.x2, obj.phi, obj.azim, obj.dets, ...
                'rotvec', obj.rotvec);
            
            % Calculated for individual detectors
            ind =   [3,1,4,1; 3,1,1,3]';
            wvec = [10,9,8,7; 10,9,9,5]'; % 1st,5th should be same; 2nd, 6th 7th the same
            paths = squeeze(bank.dmat(1,:,ind));     % extract paths from orientation matrices
            effs = effic (obj.dets, ind, paths, wvec);
            
            % Calculated for detector_array
            eff_array = bank.effic(ind, wvec);
            
            assertEqualToTol (effs, eff_array, 'tol',[1e-13,1e-13])
            assertEqualToTolWithSave (obj, eff_array, 'tol',[1e-13,1e-13])
        end
        
        %--------------------------------------------------------------------------
        function test_save_load_1 (obj)
            % Test efficiency calculation for subset of dets and with
            % different wavlengths
            % Make ind and wvec matrices for good measure!s
            bank = IX_detector_bank (obj.id, obj.x2, obj.phi, obj.azim, obj.dets, ...
                'rotvec', obj.rotvec);
            
            % Save detector bank
            test_file = fullfile (tmp_dir(), 'test_save_load_1.mat');
            cleanup = onCleanup(@()delete(test_file));
            save (test_file, 'bank');
            
            % Recover detector bank
            tmp = load (test_file);
            
            assertEqual (bank, tmp.bank)
        end
        
    end
    
end
