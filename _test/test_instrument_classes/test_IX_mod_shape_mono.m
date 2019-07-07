classdef test_IX_mod_shape_mono < TestCaseWithSave
    % Test methods of IX_mod_shape_mono
    properties
        efix
        mod_DGdisk
        shape_DGdisk
        mono_DGdisk
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_IX_mod_shape_mono (name)
            self@TestCaseWithSave(name);
            
            % Create components needed for an IX_inst_DGdisk
            % Use an old-ish LET function for convenience
            self.efix = 8;
            instru = let_instrument_struct_for_tests (self.efix, 280, 140, 20, 2, 2);
            
            self.mod_DGdisk = instru.moderator;
            self.shape_DGdisk = instru.chop_shape;
            self.mono_DGdisk = instru.chop_mono;
            
            self.save()
        end
        
        %--------------------------------------------------------------------------
        function test_covariance_mod (self)
            msm = IX_mod_shape_mono(self.mod_DGdisk, self.shape_DGdisk, self.mono_DGdisk);
            msm.shaping_chopper.frequency = 171;
            msm.energy = self.efix;
            
            % mod FWHH=99.37us, shape_chop FWHH=66.48us
            shaped_mod = msm.shaped_mod;        % should be false - but only just
            assertEqualWithSave(self,shaped_mod);
            
            [tcov,tmean] = msm.covariance;
            assertEqualToTolWithSave(self, tcov, 'tol', [1e-4,1e-4])

            npnt = 5e6;
            [tcovR,tmeanR] = rand_covariance (msm, npnt);
            assertEqualToTol(tcov, tcovR, 'tol', [0.5,2e-2])
            assertEqualToTol(tmean, tmeanR, 'tol', [0.5,2e-2])
        end
        
        %--------------------------------------------------------------------------
        function test_covariance_shape (self)
            msm = IX_mod_shape_mono(self.mod_DGdisk, self.shape_DGdisk, self.mono_DGdisk);
            msm.shaping_chopper.frequency = 172;
            msm.energy = self.efix;
            
            % FWHH=99.37us, shape_chop FWHH=66.09us
            shaped_mod = msm.shaped_mod;        % should be true - but only just
            assertEqualWithSave(self,shaped_mod);
            
            [tcov,tmean] = msm.covariance;
            assertEqualToTolWithSave(self, tcov, 'tol', [1e-4,1e-4])

            npnt = 5e6;
            [tcovR,tmeanR] = rand_covariance (msm, npnt);
            assertEqualToTol(tcov, tcovR, 'tol', [0.5,2e-2])
            assertEqualToTol(tmean, tmeanR, 'tol', [0.5,2e-2])
        end
        
        %--------------------------------------------------------------------------
        function test_covariance_mod_only (self)
            msm = IX_mod_shape_mono(self.mod_DGdisk, self.shape_DGdisk, self.mono_DGdisk);
            msm.shaping_chopper.frequency = 1;
            msm.energy = self.efix;
            
            % mod FWHH=99.37us, shape_chop FWHH=11368us
            shaped_mod = msm.shaped_mod;        % should be true - extreme case
            assertEqualWithSave(self,shaped_mod);
            
            [tcov,tmean] = msm.covariance;
            assertEqualToTolWithSave(self, tcov, 'tol', [1e-4,1e-4])

            npnt = 5e6;
            [tcovR,tmeanR] = rand_covariance (msm, npnt);
            assertEqualToTol(tcov, tcovR, 'tol', [0.5,2e-2])
            assertEqualToTol(tmean, tmeanR, 'tol', [0.5,2e-2])
        end
        
        %--------------------------------------------------------------------------
        function test_covariance_shaped_only (self)
            msm = IX_mod_shape_mono(self.mod_DGdisk, self.shape_DGdisk, self.mono_DGdisk);
            msm.moderator.pp(1)=10000;
            msm.shaping_chopper.frequency = 171;
            msm.energy = self.efix;
            
            % mod FWHH=33947us, shape_chop FWHH=66.48us
            shaped_mod = msm.shaped_mod;        % should be true - extreme case
            assertEqualWithSave(self,shaped_mod);
            
            [tcov,tmean] = msm.covariance;
            assertEqualToTolWithSave(self, tcov, 'tol', [1e-4,1e-4])

            npnt = 5e6;
            [tcovR,tmeanR] = rand_covariance (msm, npnt);
            assertEqualToTol(tcov, tcovR, 'tol', [0.5,2e-2])
            assertEqualToTol(tmean, tmeanR, 'tol', [0.5,2e-2])
        end
        
        %--------------------------------------------------------------------------
    end
end

%--------------------------------------------------------------------------
function [tcov,tmean] = rand_covariance (obj, npnt)
X = obj.rand([npnt,1]);
tcov = cov(X');
tmean = mean(X,2)';
end
