classdef test_IX_detector_array_1 < TestCaseWithSave
    % Test the calculation of quantities for IX_detector_array object
    % Detector arrays are made of banks which in turn are made of detectors
    properties
        bank1
        bank2
        bank3
        bank4
        bank5
        
        seed
        rng_state
    end
    
    methods
        %--------------------------------------------------------------------------
        function obj = test_IX_detector_array_1 (name)
            obj@TestCaseWithSave(name);
            
            % 3He bank
            % --------
            x2_1 = [10,10.1,10.2,10.3];
            phi_1 = [30,35,40,45];
            azim_1 = 45;
            det_1 = IX_det_He3tube(0.0254,0.03,0.002,10);
            
            rotvec1 = [0,0,0; 0,20,0; 0,45,0; 0,60,0]';
            obj.bank1 = IX_detector_bank (1001:1004,x2_1,phi_1,azim_1,det_1,'rotvec',rotvec1);
            
            % 3He bank
            % --------
            x2_2 = 2.5;
            phi_2 = [10,10,15,15,20,20];
            azim_2 = [0,22.5,45,67.5,90,90];
            det_2 = IX_det_He3tube(0.0125,0.015,0.002,6.3);
            
            rotvec2 = [0,10,0; 0,23,0; 0,55,0; 0,60,0; 0,65,0; 0,80,0]';
            obj.bank2 = IX_detector_bank (2001:2006,x2_2,phi_2,azim_2,det_2,'rotvec',rotvec2);
            
            % slab bank
            % ---------
            x2_3 = [2,2.1,2.2];
            phi_3 = [10,21,32];
            azim_3 = [180,180,180];
            det_3 = IX_det_slab (0.01,0.03,0.2,0.005);
            
            rotvec3 = [0,31,0; 0,28,0; 0,41,0]';
            obj.bank3 = IX_detector_bank (3001:3003,x2_3,phi_3,azim_3,det_3,'rotvec',rotvec3);

            % 3He bank
            % --------
            x2_4 = 4;
            phi_4 = [10,20,20];
            azim_4 = [10,122.5,167.5];
            det_4 = IX_det_He3tube(0.0125,0.015,0.002,[6.3,7.3,15.3]);
            
            rotvec4 = [0,3,0; 0,22,0; 0,47,0]';
            obj.bank4 = IX_detector_bank (4001:4003,x2_4,phi_4,azim_4,det_4,'rotvec',rotvec4);
            
            % slab bank
            % ---------
            % Large size
            x2_5 = 2.5;
            phi_5 = [10,10,15,15,20,20];
            azim_5 = [0,22.5,45,67.5,90,90];
            det_5 = IX_det_slab (0.2, 0.4:0.01:0.4501, 0.2:0.01:0.25001, 10);
            
            rotvec5 = [0,10,0; 0,23,0; 0,55,0; 0,60,0; 0,65,0; 0,80,0]';
            obj.bank5 = IX_detector_bank (2001:2006,x2_5,phi_5,azim_5,det_5,'rotvec',rotvec5);
            
            % Random numbers
            % --------------
            obj.seed = 0;
            
            obj.save()
        end

        function obj = setUp(obj)
            % Save current rng state and force random seed and method
            obj.rng_state = rng(obj.seed, 'twister');
        end
        
        function obj = tearDown(obj)
            % Undo rng state
            rng(obj.rng_state);
        end

        
        %--------------------------------------------------------------------------
        %   Test constructor
        %--------------------------------------------------------------------------
        function test_constructor_fromOneBank (obj)
            % Make from a single detector bank
            D = IX_detector_array (obj.bank1);
            assertEqual (D.det_bank, obj.bank1)
        end
        
        %--------------------------------------------------------------------------
        function test_constructor_fromMultipleBanks (obj)
            % Make from multiple detector banks, with different detector
            % types
            banks_123 = [obj.bank1, obj.bank2, obj.bank3];
            D = IX_detector_array (banks_123, obj.bank4);
            
            banks_1234 = [obj.bank1 obj.bank2, obj.bank3, obj.bank4];
            assertEqual (D.det_bank, banks_1234(:))
        end
        
        %--------------------------------------------------------------------------
        function test_constructor_fromDataItems (obj)
            % Check constructs with arguments as for IX_detector_bank
            B = obj.bank1;
            D = IX_detector_array (B);
            Dtest = IX_detector_array (B.id, B.x2, B.phi,...
                'det', B.det, 'rotvec', B.rotvec,'azim', B.azim);
            assertEqual (D, Dtest)
        end
        
        %--------------------------------------------------------------------------
        function test_constructor_fromDetparStruct (~)
            id = (1:99)'; 
            x2 = (0.0001:0.0001:0.0099)';
            phi = (1.8:1.8:179.999)';
            azim = (0.9:0.9:89.999)';
            width = (0.02:0.0001:0.0298999)';
            height = (0.03:0.0001:0.0398999)';
            filename = 'random_name.par';
            filepath = '';
            
            % Make detpar structure and use as input to constructor
            detpar.group = id;
            detpar.x2 = x2;
            detpar.phi = phi;
            detpar.azim = azim;
            detpar.width = width;
            detpar.height = height;
            detpar.filepath = filepath;
            detpar.filename = filename;
            
            D = IX_detector_array (detpar);
            
            % Construct directly
            dets = IX_det_TobyfitClassic (width, height);
            Dref = IX_detector_array (id, x2, phi, azim, dets);
            Dref.filename = 'random_name.par';

            assertEqual(D, Dref);
        end
        
        %--------------------------------------------------------------------------
        function test_constructor_4 (obj)
            % Check fails if there are non-unique detector id values
            bank2_tmp = obj.bank2;
            bank2_tmp.id(4) = obj.bank1.id(2);
            banks_123 = [obj.bank1, bank2_tmp, obj.bank3];
            ME = assertExceptionThrown( ...
                @()IX_detector_array (banks_123, obj.bank4), ...
                'HERBERT:IX_detector_array:invalid_argument');
            assertEqual(ME.message, 'Detector identifiers must all be unique')
        end
        
        %--------------------------------------------------------------------------
        %   Test changing properties
        %--------------------------------------------------------------------------
        function test_change_id (obj)
            D = IX_detector_array (obj.bank1, obj.bank2, obj.bank3);
            D.id = 101:113;
            assertEqual (D.id, (101:113)');
        end

        function test_change_id_error (obj)
            % Throw error as id not all unique
            D = IX_detector_array (obj.bank1, obj.bank2, obj.bank3);
            try
                D.id = [101:102,111,104:113];
            catch ME
                assertEqual(ME.identifier, 'HERBERT:IX_detector_array:invalid_argument')
                return
            end
            error('Should have failed on invalid detector identifiers')
        end

        function test_change_x2 (obj)
            D = IX_detector_array (obj.bank1, obj.bank2, obj.bank3);
            D.x2 = 101:113;
            assertEqual (D.x2, (101:113)');
        end

        function test_change_phi (obj)
            D = IX_detector_array (obj.bank1, obj.bank2, obj.bank3);
            D.phi = 101:113;
            assertEqual (D.phi, (101:113)');
        end

        function test_change_phi_error (obj)
            % Throw error as phi out of range for one detector
            % This will have been picked up in the relevant set method for
            % IX_detector_bank
            D = IX_detector_array (obj.bank1, obj.bank2, obj.bank3);
            try
                D.phi = [101:102,231,104:113];
            catch ME
                assertEqual(ME.identifier, 'HERBERT:IX_detector_array:invalid_argument')
                return
            end
            error('Should have failed on invalid value of phi')
        end

        function test_change_azim (obj)
            D = IX_detector_array (obj.bank1, obj.bank2, obj.bank3);
            D.azim = 101:113;
            assertEqual (D.azim, (101:113)');
        end

        function test_change_dmat (obj)
            D = IX_detector_array (obj.bank1, obj.bank2, obj.bank3);
            dmat = rotvec_to_rotmat ([11:23; 101:113; -20:-8]);
            D.dmat = dmat;
            assertEqual (D.dmat, dmat);
        end

        function test_change_rotvec (obj)
            D = IX_detector_array (obj.bank1, obj.bank2, obj.bank3);
            D.rotvec = [11:23; 101:113; -20:-8];
            assertEqualToTol (D.rotvec, [11:23; 101:113; -20:-8], 'abstol', 1e-13);
        end

        
        %--------------------------------------------------------------------------
        %   Test save and load
        %--------------------------------------------------------------------------
        function test_save_load_1 (obj)
            % Test save and load: save then reload, and check identical
            banks_123 = [obj.bank1, obj.bank2, obj.bank3];
            D = IX_detector_array (banks_123, obj.bank4);
            
            % Save detector bank
            test_file = fullfile (tmp_dir(), 'test_save_load_1.mat');
            cleanup = onCleanup(@()delete(test_file));
            save (test_file, 'D');
            
            % Recover detector bank
            tmp = load (test_file);
            
            assertEqual (D, tmp.D)
        end
        
        
        %--------------------------------------------------------------------------
        %   Test methods
        %--------------------------------------------------------------------------
        function test_effic_oneBank_allDet_oneWvec (obj)
            % Efficiencies for a whole bank, one wvec
            D = IX_detector_array (obj.bank1);
            
            wvec = 10;
            eff = effic (D, wvec);  % whole bank
            
            eff_ref = effic (obj.bank1, wvec);
            assertEqual (eff, eff_ref)
        end
        
        function test_effic_oneBank_allDet_manyWvec (obj)
            % Efficiencies for a whole bank, many wvec
            D = IX_detector_array (obj.bank1);
            
            wvec = logspace(1,0.5,obj.bank1.ndet);
            eff = effic (D, wvec);  % whole bank
            
            eff_ref = effic (obj.bank1, wvec);
            assertEqual (eff, eff_ref)
        end
        
        function test_effic_oneBank_manyDet_oneWvec (obj)
            % Efficiencies for one bank, multiple calls to at least some
            % detectors, one wvec
            D = IX_detector_array (obj.bank1);
            
            ind = [2,3,3,4,2,4];
            wvec = 10;
            eff = effic (D, ind, wvec);
            
            assertEqual (eff(4), eff(6))
            
            eff_ref = effic (obj.bank1, ind, wvec);
            assertEqual (eff, eff_ref)
        end
        
        function test_effic_oneBank_manyDet_manyWvec (obj)
            % Efficiencies for one bank, multiple calls to at least some
            % detectors, multiple wvec
            D = IX_detector_array (obj.bank1);
            
            ind = [2,3,3,4,2,4];
            wvec = logspace(1,0.5,numel(ind));
            eff = effic (D, ind, wvec);
            
            eff_ref = effic (obj.bank1, ind, wvec);
            assertEqual (eff, eff_ref)
        end
        
        function test_effic_oneBank_manyDet_manyWvec_2 (obj)
            % Efficiencies for one bank, multiple calls to at least some
            % detectors, multiple wvec
            % Now have a 2D array of ind and wvec; different sizes but output
            % should have size of wvec (convention for IX_det_*)
            D = IX_detector_array (obj.bank1);
            
            ind = [2,3,3; 4,2,4; 2,4,3; 4,3,2];
            wvec = reshape (logspace(1,0.5,numel(ind)), [6,2]);
            eff = effic (D, ind, wvec);
            
            assertEqual (size(eff), [6,2]);
            
            eff_ref = effic (obj.bank1, ind, wvec);
            assertEqual (eff, eff_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_effic_twoBanks_allDet_oneWvec (obj)
            % Efficiencies for two whole banks, one wvec
            D = IX_detector_array (obj.bank1, obj.bank2);
            
            wvec = 10;
            eff = effic (D, wvec);  % whole bank
            
            eff1 = effic (obj.bank1, wvec);
            eff2 = effic (obj.bank2, wvec);
            assertEqual (eff, [eff1, eff2])
        end
        
        function test_effic_twoBanks_allDet_manyWvec (obj)
            % Efficiencies for two whole banks, many wvec
            D = IX_detector_array (obj.bank1, obj.bank2);
            
            wvec = logspace(1,0.5,D.ndet);
            eff = effic (D, wvec);  % whole bank
            
            ndet1 = obj.bank1.ndet;
            ndet2 = obj.bank2.ndet;
            eff1 = effic (obj.bank1, wvec(1:ndet1));
            eff2 = effic (obj.bank2, wvec(ndet1+1:ndet1+ndet2));
            assertEqual (eff, [eff1, eff2])
        end
        
        function test_effic_twoBanks_manyDet_oneWvec (obj)
            % Efficiencies for two banks, multiple calls to at least some
            % detectors from each bank, one wvec
            D = IX_detector_array (obj.bank1, obj.bank2);
            
            ind = [...
                2     6     8     9     3     7
                7     4     6     2     9     6
                6     5     9     6     3     7
                4    10     5     4     3     3];
            wvec = 10;
            eff = effic (D, ind, wvec);
            
            ix1 = [1,4,6,14,16,17,19,20,24];
            ix2 = [2,3,5,7,8,9,10,11,12,13,15,18,21,22,23];
            eff1 = effic (obj.bank1, ind(ix1), wvec);
            eff2 = effic (obj.bank2, ind(ix2)-4, wvec);
            eff_ref = zeros(size(ind));
            eff_ref(ix1) = eff1;
            eff_ref(ix2) = eff2;
            
            assertEqual (eff, eff_ref)
        end
        
        function test_effic_twoBanks_manyDet_manyWvec (obj)
            % Efficiencies for two banks, multiple calls to at least some
            % detectors from each bank, multiple wvec
            % Now have a 2D array of ind and wvec; different sizes but output
            % should have size of wvec (convention for IX_det_*)
            D = IX_detector_array (obj.bank1, obj.bank2);
            
            ind = [...
                2     6     8     9     3     7
                7     4     6     2     9     6
                6     5     9     6     3     7
                4    10     5     4     3     3];
            wvec = reshape(logspace(1,0.5,numel(ind)), [3,8]);
            eff = effic (D, ind, wvec);
            
            ix1 = [1,4,6,14,16,17,19,20,24];
            ix2 = [2,3,5,7,8,9,10,11,12,13,15,18,21,22,23];
            col = @(x)(x(:));
            eff1 = effic (obj.bank1, col(ind(ix1)), col(wvec(ix1)));
            eff2 = effic (obj.bank2, col(ind(ix2))-4, col(wvec(ix2)));
            eff_ref = zeros(size(wvec));
            eff_ref(ix1) = eff1;
            eff_ref(ix2) = eff2;
            
            assertEqual (eff, eff_ref)
        end
        
        
        function test_mean_twoBanks_manyDet_manyWvec (obj)
            % Mean point of absorbtion for two banks, multiple calls to at least some
            % detectors from each bank, multiple wvec
            % Mean for a single detector is a [3,1] vector. Check the correct
            % assembly of output array size, which should have outer dimensions
            % set by the size of wvec.
            % Have a 2D array of ind and wvec; different sizes but output
            % should have size of wvec (convention for IX_det_*)
            D = IX_detector_array (obj.bank1, obj.bank2);
            
            ind = [...
                2     6     8     9     3     7
                7     4     6     2     9     6
                6     5     9     6     3     7
                4    10     5     4     3     3];
            
            % Expected output size (3,2,12):
            % ------------------------------
            wvec = reshape(logspace(1,0.5,numel(ind)), [2,12]);
            meanpos = mean (D, ind, wvec);
            
            ix1 = [1,4,6,14,16,17,19,20,24];
            ix2 = [2,3,5,7,8,9,10,11,12,13,15,18,21,22,23];
            col = @(x)(x(:));
            meanpos1 = mean (obj.bank1, col(ind(ix1)), col(wvec(ix1)));
            meanpos2 = mean (obj.bank2, col(ind(ix2))-4, col(wvec(ix2)));
            meanpos_ref = zeros(3,24);
            meanpos_ref(:,ix1) = meanpos1;
            meanpos_ref(:,ix2) = meanpos2;
            meanpos_ref = reshape(meanpos_ref, [3,2,12]);
            
            assertEqual (meanpos, meanpos_ref)
            
            % Expected output size (3,24):
            % ------------------------------
            wvec = reshape(logspace(1,0.5,numel(ind)), [1,24]);
            meanpos = mean (D, ind, wvec);
            
            ix1 = [1,4,6,14,16,17,19,20,24];
            ix2 = [2,3,5,7,8,9,10,11,12,13,15,18,21,22,23];
            col = @(x)(x(:));
            meanpos1 = mean (obj.bank1, col(ind(ix1)), col(wvec(ix1)));
            meanpos2 = mean (obj.bank2, col(ind(ix2))-4, col(wvec(ix2)));
            meanpos_ref = zeros(3,24);
            meanpos_ref(:,ix1) = meanpos1;
            meanpos_ref(:,ix2) = meanpos2;
            
            assertEqual (meanpos, meanpos_ref)
        end
        
        function test_cov_twoBanks_manyDet_manyWvec (obj)
            % Covariance of point of absorbtion for two banks, multiple calls to at least some
            % detectors from each bank, multiple wvec
            % Covariance for a single detector is a [3,3] array. Check the correct
            % assembly of output array size, which should have outer dimensions
            % set by the size of wvec.
            % Have a 2D array of ind and wvec; different sizes but output
            % should have size of wvec (convention for IX_det_*)
            D = IX_detector_array (obj.bank1, obj.bank2);
            
            ind = [...
                2     6     8     9     3     7
                7     4     6     2     9     6
                6     5     9     6     3     7
                4    10     5     4     3     3];
            
            % Expected output size (3,3,2,12):
            % --------------------------------
            wvec = reshape(logspace(1,0.5,numel(ind)), [2,12]);
            covpos = covariance (D, ind, wvec);
            
            ix1 = [1,4,6,14,16,17,19,20,24];
            ix2 = [2,3,5,7,8,9,10,11,12,13,15,18,21,22,23];
            col = @(x)(x(:));
            covpos1 = covariance (obj.bank1, col(ind(ix1)), col(wvec(ix1)));
            covpos2 = covariance (obj.bank2, col(ind(ix2))-4, col(wvec(ix2)));
            covpos_ref = zeros(3,3,24);
            covpos_ref(:,:,ix1) = covpos1;
            covpos_ref(:,:,ix2) = covpos2;
            covpos_ref = reshape(covpos_ref, [3,3,2,12]);
            
            assertEqual (covpos, covpos_ref)
            
            % Expected output size (3,3,24):
            % ------------------------------
            wvec = reshape(logspace(1,0.5,numel(ind)), [1,24]);
            covpos = covariance (D, ind, wvec);
            
            ix1 = [1,4,6,14,16,17,19,20,24];
            ix2 = [2,3,5,7,8,9,10,11,12,13,15,18,21,22,23];
            col = @(x)(x(:));
            covpos1 = covariance (obj.bank1, col(ind(ix1)), col(wvec(ix1)));
            covpos2 = covariance (obj.bank2, col(ind(ix2))-4, col(wvec(ix2)));
            covpos_ref = zeros(3,3,24);
            covpos_ref(:,:,ix1) = covpos1;
            covpos_ref(:,:,ix2) = covpos2;
            
            assertEqual (covpos, covpos_ref)
        end
        
        
%         %--------------------------------------------------------------------------
%         %   Test random numbers
%         %--------------------------------------------------------------------------
%         function test_random_points (obj)
%             % Two detector banks; first has gas tubes dia 0.0254m, the second
%             % has hardly absorbing slab detctors with size >10cm. Can use this
%             % to test random numbers being selected from correct detector type
%             D = IX_detector_array (obj.bank1, obj.bank5);
%             
%             % Get approx. np repetitions of each detector index
%             ndet = D.ndet;
%             np = 1000;  % number of points to sample from each detector
%             ind = repmat(1:ndet, [2*np,1]);
%             ind = ind(randperm(numel(ind),np*ndet));
%             ind = reshape (ind, [25*ndet, 40]);
%             
%             % Constant wavevector
%             wvec = 10;
%             
%             % Random points, from random order of detector indices
%             X = D.rand (ind, wvec);
%             assertEqual (size(X), [3, 25*ndet, 40])
%             
%             % Now unravel range of x, y, z for each detector
%             X = reshape (X, [3, numel(X)/3]);
%             Xmin = NaN(3,ndet);
%             Xmax = NaN(3,ndet);
%             for i=1:ndet
%                 Xmin(:,i) = min(X(:,i), [], 2);
%                 Xmax(:,i) = max(X(:,i), [], 2);
%             end
%         end

    end
    
end
