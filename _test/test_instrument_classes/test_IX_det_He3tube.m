classdef test_IX_det_He3tube < TestCaseWithSave
    % Test the calculation of quantities for IX_det_He3tube object
    properties
        dia
        height
        wall
        atms
        path
    end
    
    methods
        %--------------------------------------------------------------------------
        function obj = test_IX_det_He3tube (name)
            obj@TestCaseWithSave(name);
            
            % Arrays for construction of detectors
            % Note: have varying paths w.r.t. detector coordinate frame
            dia(1) = 0.0254;  height(1) = 0.015; wall(1) = 6.35e-4; atms(1) = 10; th(1) = pi/2;
            dia(2) = 0.0300;  height(2) = 0.025; wall(2) = 10.0e-4; atms(2) = 6;  th(2) = 0.9;
            dia(3) = 0.0400;  height(3) = 0.035; wall(3) = 15.0e-4; atms(3) = 4;  th(3) = 0.775;
            dia(4) = 0.0400;  height(4) = 0.035; wall(4) = 15.0e-4; atms(4) = 7;  th(4) = 0.775;
            dia(5) = 0.0400;  height(5) = 0.035; wall(5) = 15.0e-4; atms(5) = 9;  th(5) = 0.775;
            
            obj.dia = dia;
            obj.height = height;
            obj.wall = wall;
            obj.atms = atms;
            obj.path = [sin(th); zeros(size(th)); cos(th)];
            
            obj.save()
        end
        
        %--------------------------------------------------------------------------
        function test_det_constructor (obj)
            [~, det_array] = construct_detectors (obj);
            assertEqual (obj.dia(:), det_array.dia)
            assertEqual (obj.height(:), det_array.height)
            assertEqual (obj.wall(:), det_array.wall)
            assertEqual (obj.atms(:), det_array.atms)
        end
        
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
%            assertEqualToTolWithSave (obj, eff_array, 'tol',[1e-13,1e-13])
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
%            assertEqualToTolWithSave (obj, eff_array, 'tol',[1e-13,1e-13])
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
%            assertEqualToTolWithSave (obj, eff_array, 'tol',[1e-13,1e-13])
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
        % Utility methods
        %--------------------------------------------------------------------------
        function [dets, det_array] = construct_detectors (obj)
            % Create array of single IX_det_He3tube objects, and the 
            % equivalent IX_det_He3tube object containing an array of
            % detectors.
            dets = repmat(IX_det_He3tube, [1,5]);
            for i=1:5
                dets(i) = IX_det_He3tube (obj.dia(i), obj.height(i), obj.wall(i), obj.atms(i));
            end
            det_array = IX_det_He3tube (obj.dia, obj.height, obj.wall, obj.atms);
            
        end
        
        %--------------------------------------------------------------------------
    end
    
    
end
