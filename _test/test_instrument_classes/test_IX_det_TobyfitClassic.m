classdef test_IX_det_TobyfitClassic < TestCaseWithSave
    % Test the calculation of quantities for IX_det_TobyfitClassic object
    properties
        dia
        height
        path
        
        seed
        rng_state
    end
    
    methods
        %--------------------------------------------------------------------------
        function obj = test_IX_det_TobyfitClassic (name)
            obj@TestCaseWithSave(name);
            
            % Arrays for construction of detectors
            % Note: have varying paths w.r.t. detector coordinate frame
            obj.dia =    [0.0254 , 0.0300 , 0.0400 , 0.0400 , 0.0400 ];
            obj.height = [0.015  , 0.025  , 0.035  , 0.035  , 0.035  ];
            th =         [pi/2   , 0.9    , 0.775  , 0.775  , 0.775  ];
            obj.path = [sin(th); zeros(size(th)); cos(th)];
            
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
            assertEqual (obj.dia(:), det_array.dia)
            assertEqual (obj.height(:), det_array.height)
        end
        
        function test_det_constructor_argExpand (obj)
            % Test constructor with one scalar argument input
            val = 0.00344;
            det_array = IX_det_TobyfitClassic (val, obj.height);
            assertEqual (val.*ones(size(obj.dia(:))), det_array.dia)
            assertEqual (obj.height(:), det_array.height)
        end
        
        function test_det_constructor_tooFewArgs_THROW (obj)
            % Test constructor with insufficient input arguments
            % Should throw error
            assertExceptionThrown( ...
                @()IX_det_TobyfitClassic (obj.dia), ...
                'HERBERT:serializable:invalid_argument');
        end
        
        function test_det_constructor_tooManyArgs_THROW (obj)
            % Test constructor with too many input arguments
            % Should throw error
            assertExceptionThrown( ...
                @()IX_det_TobyfitClassic (obj.dia, obj.height, 0.1), ...
                'HERBERT:IX_det_TobyfitClassic:invalid_argument');
        end
        
        function test_det_constructor_mixPosKeywrdArgs (obj)
            % Test constructor with mixed positional and keyword arguments in
            % non-standard order
            
            % Reference array
            [~, det_array_ref] = construct_detectors (obj);
            
            % Equivalent
            det_array = IX_det_TobyfitClassic (obj.dia, 'height', obj.height);
            
            assertEqual (det_array_ref, det_array)
        end
        
        %--------------------------------------------------------------------------
        %   Test methods
        %--------------------------------------------------------------------------
        function test_effic_allDets_singleWvec (obj)
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
            
            assertEqualToTol (ones(1,5), eff_array, 'tol',[1e-13,1e-13])
            assertEqualToTol (effs, eff_array, 'tol',[1e-13,1e-13])
            assertEqualToTolWithSave (obj, eff_array, 'tol',[1e-13,1e-13])
        end
        
        %--------------------------------------------------------------------------
        function test_effic_arrInd_singleWvec (obj)
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
            assertEqualToTol (ones(size(ind)), eff_array, 'tol',[1e-13,1e-13])
            assertEqualToTolWithSave (obj, eff_array, 'tol',[1e-13,1e-13])
        end
        
        %--------------------------------------------------------------------------
        function test_effic_singleInd_arrWvec (obj)
            % Test efficiency calculation, single det
            % and different wavlengths
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
            assertEqualToTol (ones(1,5), eff_array, 'tol',[1e-13,1e-13])
            assertEqualToTolWithSave (obj, eff_array, 'tol',[1e-13,1e-13])
        end
        
        %--------------------------------------------------------------------------
        function test_effic_arrInd_arrWvec (obj)
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
            assertEqualToTol (ones(1,4), eff_array, 'tol',[1e-13,1e-13])
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
            assertEqualToTol (zeros(1,5), mean_d_array, 'tol', [1e-13,1e-13])
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
        function test_random_points (~)
            dia0 = 0.01; height0 = 0.03;
            det = IX_det_TobyfitClassic (dia0, height0);

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
            % Create array of single IX_det_TobyfitClassic objects, and the 
            % equivalent IX_det_TobyfitClassic object containing an array of
            % detectors.
            dets = repmat(IX_det_TobyfitClassic, [1,5]);
            for i=1:5
                dets(i) = IX_det_TobyfitClassic (obj.dia(i), obj.height(i));
            end
            det_array = IX_det_TobyfitClassic (obj.dia, obj.height);
            
        end
        
        %--------------------------------------------------------------------------
    end
    
end
