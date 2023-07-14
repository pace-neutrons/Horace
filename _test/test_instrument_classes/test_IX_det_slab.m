classdef test_IX_det_slab < TestCaseWithSave
    % Test the calculation of quantities for IX_det_slab object
    properties
        depth
        width
        height
        atten
        path
        
        seed
        rng_state
    end
    
    methods
        %--------------------------------------------------------------------------
        function obj = test_IX_det_slab (name)
            obj@TestCaseWithSave(name);
            
            % Arrays for construction of detectors
            % Note: have varying paths w.r.t. detector coordinate frame
            depth(1) = 0.10; width(1) = 0.20; height(1) = 0.30; atten(1) = 0.10; th(1) = 0;
            depth(2) = 0.12; width(2) = 0.22; height(2) = 0.32; atten(2) = 0.08; th(2) = 10;
            depth(3) = 0.14; width(3) = 0.24; height(3) = 0.34; atten(3) = 0.06; th(3) = 20;
            depth(4) = 0.16; width(4) = 0.26; height(4) = 0.36; atten(4) = 0.04; th(4) = 30;
            depth(5) = 0.18; width(5) = 0.28; height(5) = 0.38; atten(5) = 0.02; th(5) = 40;

            obj.depth = depth;
            obj.width = width;
            obj.height = height;
            obj.atten = atten;
            obj.path = [cos(th); zeros(size(th)); sin(th)];
            
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
        function test_det_constructor (obj)
            [~, det_array] = construct_detectors (obj);
            assertEqual (obj.depth(:), det_array.depth)
            assertEqual (obj.width(:), det_array.width)
            assertEqual (obj.height(:), det_array.height)
            assertEqual (obj.atten(:), det_array.atten)
        end
        
        function test_det_constructor_2 (obj)
            % Test constructor with one scalar argument input
            val = 0.00344;
            det_array = IX_det_slab (obj.depth, obj.width, val, obj.atten);
            assertEqual (obj.depth(:), det_array.depth)
            assertEqual (obj.width(:), det_array.width)
            assertEqual (val*ones(size(obj.depth(:))), det_array.height)
            assertEqual (obj.atten(:), det_array.atten)
        end
        
        function test_det_constructor_3 (obj)
            % Test constructor with insufficient input arguments
            % Should throw error
            assertExceptionThrown( ...
                @()IX_det_slab (obj.depth, obj.width, obj.height), ...
                'HERBERT:serializable:invalid_argument');
        end
        
        function test_det_constructor_4 (obj)
            % Test constructor with too many input arguments
            % Should throw error
            assertExceptionThrown( ...
                @()IX_det_slab (obj.depth, obj.width, obj.height), ...
                'HERBERT:serializable:invalid_argument');
        end
        
        function test_det_constructor_5 (obj)
            % Test constructor with mixed positional and keyword arguments in
            % non-standard order
            
            % Reference array
            [~, det_array_ref] = construct_detectors (obj);
            
            % Equivalent
            det_array = IX_det_slab (obj.depth, obj.width, ...
                'atten', obj.atten, 'height', obj.height);
            
            assertEqual (det_array_ref, det_array)
        end
        
        %--------------------------------------------------------------------------
        %   Test methods
        %--------------------------------------------------------------------------
        function test_effic_1 (obj)
            % Test efficiency calculation
            [dets, det_array] = construct_detectors (obj);
            wvec = 10;
            
            % Calculated for individual detectors
            effs = zeros(1,5);
            for i=1:5
                effs(i)   = dets(i).effic(obj.path(:,i), wvec);
            end
            
            % Calculated for detector_array
            eff_array = det_array.effic (obj.path, wvec);
            
            assertEqualToTol (effs, eff_array, 'tol',[1e-13,1e-13])
            assertEqualToTolWithSave (obj, eff_array, 'tol',[1e-13,1e-13])
        end
        
        %--------------------------------------------------------------------------
        function test_effic_2 (obj)
            % Test efficiency calculation, with explicit index ordering
            [dets, det_array] = construct_detectors (obj);
            wvec = 10;
            
            % Calculated for individual detectors
            effs = zeros(1,5);
            for i=1:5
                effs(i)   = dets(i).effic(obj.path(:,i), wvec);
            end
            
            % Calculated for detector_array
            ind = [3,1,4,1];
            eff_array = det_array.effic (ind, obj.path(:,ind), wvec);
            
            assertEqualToTol (effs(ind), eff_array, 'tol',[1e-13,1e-13])
            assertEqualToTolWithSave (obj, eff_array, 'tol',[1e-13,1e-13])
        end
        
        %--------------------------------------------------------------------------
        function test_effic_3 (obj)
            % Test efficiency calculation, with explicit index ordering
            [dets, det_array] = construct_detectors (obj);
            wvec = [10,9,8,7,6];
            
            % Calculated for detector 4, once per wavevector
            effs = zeros(1,5);
            for i=1:5
                effs(i)   = dets(4).effic(obj.path(:,4), wvec(i));
            end
            
            % Calculated for detector_array
            ind = [4,4,4,4,4];
            eff_array = det_array.effic (ind, obj.path(:,ind), wvec);
            
            assertEqualToTol (effs, eff_array, 'tol',[1e-13,1e-13])
            assertEqualToTolWithSave (obj, eff_array, 'tol',[1e-13,1e-13])
        end
        
        %--------------------------------------------------------------------------
        function test_effic_4 (obj)
            % Test efficiency calculation, with explicit index ordering
            % and different wavlengths
            [dets, det_array] = construct_detectors (obj);
            wvec = [10,9,8,7,6];
            
            % Calculated for individual detectors
            effs = zeros(1,5);
            for i=1:5
                effs(i)   = dets(i).effic(obj.path(:,i), wvec(i));
            end
            
            % Calculated for detector_array
            ind = [3,1,4,1];
            eff_array = det_array.effic (ind, obj.path(:,ind), wvec(ind));
            
            assertEqualToTol (effs(ind), eff_array, 'tol',[1e-13,1e-13])
            assertEqualToTolWithSave (obj, eff_array, 'tol',[1e-13,1e-13])
        end
        
        %--------------------------------------------------------------------------
        function test_mean_d (obj)
            % Test mean calculation
            [dets,det_array] = construct_detectors (obj);
            wvec = 10;
            
            % Calculated for individual detectors
            means_d = zeros(1,5);
            for i=1:5
                means_d(i)= dets(i).mean_d(obj.path(:,i), wvec);
            end
            
            % Calculated for detector_array
            mean_d_array = det_array.mean_d (obj.path, wvec);

            assertEqualToTol (means_d, mean_d_array, 'tol', [1e-13,1e-13])
            assertEqualToTolWithSave (obj, mean_d_array, 'tol', [1e-13,1e-13])
        end
        
        %--------------------------------------------------------------------------
        function test_var_d (obj)
            % Test variance calculation
            [dets,det_array] = construct_detectors (obj);
            wvec = 10;
            
            % Calculated for individual detectors
            vars_d = zeros(1,5);
            for i=1:5
                vars_d(i)   = dets(i).var_d(obj.path(:,i), wvec);
            end
            
            % Calculated for detector_array
            var_d_array = det_array.var_d (obj.path, wvec);

            assertEqualToTol (vars_d, var_d_array, 'tol', [1e-13,1e-13])
            assertEqualToTolWithSave (obj, var_d_array, 'tol', [1e-13,1e-13])
        end
        
        
        %--------------------------------------------------------------------------
        %   Test random numbers
        %--------------------------------------------------------------------------
        function test_random_points_noAtten (~)
            % Do for atten0 = 1e6, 1e-6, 0.05
            depth0 = 0.1; width0 = 0.03; height0 = 0.5; atten0 = 1e-8;
            det = IX_det_slab (depth0, width0, height0, atten0);
            
            nsamples = 1e5;
            ntol = 3;
            npath = [1,1,0];
            wvec = 1;
            [ok, mess] = validate_det_rand (det, nsamples, ntol, npath, wvec);
            assertTrue (ok, mess)
        end

        function test_random_points_fullAtten (~)
            % Do for atten0 = 1e6, 1e-6, 0.05
            depth0 = 0.1; width0 = 0.03; height0 = 0.5; atten0 = 1e8;
            det = IX_det_slab (depth0, width0, height0, atten0);
            
            nsamples = 1e5;
            ntol = 3;
            npath = [1,1,0];
            wvec = 1;
            [ok, mess] = validate_det_rand (det, nsamples, ntol, npath, wvec);
            assertTrue (ok, mess)
        end
        
        function test_random_points_intermediateAtten (~)
            % Do for atten0 = 1e6, 1e-6, 0.05
            depth0 = 0.1; width0 = 0.03; height0 = 0.5; atten0 = 0.05;
            det = IX_det_slab (depth0, width0, height0, atten0);
            
            nsamples = 1e5;
            ntol = 3;
            npath = [1,1,0];
            wvec = 1;
            [ok, mess] = validate_det_rand (det, nsamples, ntol, npath, wvec);
            assertTrue (ok, mess)
        end
        
        
        %--------------------------------------------------------------------------
        % Utility methods
        %--------------------------------------------------------------------------
        function [dets, det_array] = construct_detectors (obj)
            % Create array of single IX_det_slab objects, and the 
            % equivalent IX_det_slab object containing an array of
            % detectors.
            dets = repmat(IX_det_slab, [1,5]);
            for i=1:5
                dets(i) = IX_det_slab (obj.depth(i), obj.width(i), obj.height(i), obj.atten(i));
            end
            det_array = IX_det_slab (obj.depth, obj.width, obj.height, obj.atten);
        end
        
        %--------------------------------------------------------------------------
    end
    
end
