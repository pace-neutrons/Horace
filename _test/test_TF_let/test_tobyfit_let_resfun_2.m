classdef test_tobyfit_let_resfun_2 < TestCaseWithSave
    %TEST_TOBYFIT_RESFUN_2 Tests of resolution function plotting
    
    properties
        ebin
        instru
        sample
        det
        efix
        emode
        alatt
        angdeg
        u
        v
        tolerance
    end
    
    methods
        %--------------------------------------------------------------------------
        function obj = test_tobyfit_let_resfun_2 (name)
            obj = obj@TestCaseWithSave(name);
            
            % Make instrument and sample
            efix = 8.04;
            instru = let_instrument_obj_for_tests (efix, 280, 140, 20, 2, 2);
            alatt = [3.3,3.3,3.3];
            angdeg = [90,90,90];
            sample = IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.012,0.012,0.04]);
            sample.alatt = alatt;
            sample.angdeg = angdeg;
            
            % Make some detectors
            det.x2=3.5;
            det.phi=60;
            det.azim=0;
            det.width=0.025;
            det.height=0.04;
            
            % Populate the test object
            obj.ebin = [2-0.01,2+0.01];
            obj.instru = instru;
            obj.sample = sample;
            obj.det = det;
            obj.efix = 8.04;
            obj.emode = 1;
            obj.alatt = alatt;
            obj.angdeg = angdeg;
            obj.u = [1,1,0];
            obj.v = [0,0,1];
            
            obj.tolerance = [1e-12, 1e-8];
            
            obj.save()
        end
        
        
        %--------------------------------------------------------------------------
        function test_projaxes_1(S)
            % Axes [1,2]
            ww1 = resolution_plot(S.ebin, S.instru, S.sample, S.det, S.efix, S.emode,...
                S.alatt, S.angdeg, S.u, S.v, 0, 0, 0, 0, 0);
            
            % Save
            assertEqualToTolWithSave (S, ww1, 'tol', S.tolerance)
            
        end
        
        %--------------------------------------------------------------------------
        function test_projaxes_2(S)
            % Axes [1,4]
            iax = [1,4];
            ww2 = resolution_plot(S.ebin, S.instru, S.sample, S.det, S.efix, S.emode,...
                S.alatt, S.angdeg, S.u, S.v, 0, 0, 0, 0, 0, iax);
            
            % Save
            assertEqualToTolWithSave (S, ww2, 'tol', S.tolerance)
            
        end
        
        %--------------------------------------------------------------------------
    end
end
