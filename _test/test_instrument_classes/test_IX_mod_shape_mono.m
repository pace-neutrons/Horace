classdef test_IX_mod_shape_mono < TestCaseWithSave
    % Test methods of IX_mod_shape_mono
    properties
        efix
        mod_DGdisk
        shape_DGdisk
        mono_DGdisk

        home_folder;
    end
    
    methods
        %--------------------------------------------------------------------------
        function obj = test_IX_mod_shape_mono (name)
            home_folder = fileparts(mfilename('fullpath'));
            if nargin == 0
                name = 'test_IX_mod_shape_mono';
            end
            file = fullfile(home_folder,'test_IX_mod_shape_mono_output.mat');
            obj@TestCaseWithSave(name,file);
            obj.home_folder = home_folder;            
            
            
            % Create components needed for an IX_inst_DGdisk
            % Use an old-ish LET function for convenience
            obj.efix = 8;
            instru = let_instrument_struct_for_tests (obj.efix, 280, 140, 20, 2, 2);
            
            obj.mod_DGdisk = instru.moderator;
            obj.shape_DGdisk = instru.chop_shape;
            obj.mono_DGdisk = instru.chop_mono;
            
            obj.save()
        end
        
        %--------------------------------------------------------------------------
        function test_covariance_mod (self)
            msm = IX_mod_shape_mono(self.mod_DGdisk, self.shape_DGdisk, self.mono_DGdisk);
            msm.shaping_chopper.frequency = 171;
            msm.energy = self.efix;
            
            % mod FWHH=99.37us, shape_chop FWHH=66.48us
            shaped_mod = msm.shaped_mod;        % should be false - but only just
            assertEqualWithSave(self,shaped_mod);
            
            tcov = msm.covariance();
            tmean = msm.mean();
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
            
            tcov = msm.covariance();
            tmean = msm.mean();
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
            
            tcov = msm.covariance();
            tmean = msm.mean();
            assertEqualToTolWithSave(self, tcov, 'tol', [1e-4,1e-4])

            npnt = 5e6;
            [tcovR,tmeanR] = rand_covariance (msm, npnt);
            assertEqualToTol(tcov, tcovR, 'tol', [0.5,4e-2])
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
            assertTrue(shaped_mod);
            
            tcov = msm.covariance();
            tmean = msm.mean();
            assertEqualToTolWithSave(self, tcov, 'tol', [1e-4,1e-4])

            npnt = 5e6;
            [tcovR,tmeanR] = rand_covariance (msm, npnt);
            assertEqualToTol(tcov, tcovR, 'tol', [0.5,2e-2])
            assertEqualToTol(tmean, tmeanR, 'tol', [0.5,2e-2])
        end        
        %--------------------------------------------------------------------------
        function test_prev_versions(obj)
            % Scalar example
            mod_sm = IX_mod_shape_mono(obj.mod_DGdisk, obj.shape_DGdisk, obj.mono_DGdisk);
            sample_files_location = obj.home_folder;
            if obj.save_output
                % run test_IX_apperture with -save option to obtain reference
                % files before changed to new class version
                save_variables=true;
                ver = mod_sm.classVersion();
                verstr = ['ver',num2str(ver)];
                check_matfile_IO(verstr, save_variables, sample_files_location,mod_sm);

            else
                save_variables=false;

                verstr= 'ver1';
                check_matfile_IO(verstr, save_variables, sample_files_location ,mod_sm);
            end

        end
        
    end
end

%--------------------------------------------------------------------------
function [tcov,tmean] = rand_covariance (obj, npnt)
X = obj.rand([npnt,1]);
tcov = cov(X');
tmean = mean(X,2);
end
