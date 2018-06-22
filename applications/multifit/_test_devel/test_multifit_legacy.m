classdef test_multifit_legacy < TestCaseWithSave
    % Test multifit and legacy version
    properties
        data    % input data for the test suite
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_multifit_legacy (name)
            self@TestCaseWithSave(name);
            
            datafile = fullfile(fileparts(mfilename('fullpath')),'testdata_multifit_1.mat');
            self.data = load(datafile);
            
            self.save()
        end
        
        %--------------------------------------------------------------------------
        function test_struct_1d (self)
            % Test fitting of structure array of three 1D datasets
            S = self.data;
            Sarr = [S.s1,S.s2,S.s3];   % array of three datasets
            
            % Ensure fit control parameters are the same for old and new multifit
            fcp = [0.0001 30 0.0001];
            
            % An example fit with old multifit
            nlist = 0;  % set to 0,1 or 2 for increasing verbosity
            [fit_legacy.warr,fit_legacy.par] = multifit (Sarr,...
                @mftest_gauss, [100,45,10], @mftest_bkgd, {[10,0],[20,0],[30,0]},...
                'fitcontrolparameters',fcp,...
                'list', nlist);
            
            % Same with mfclass
            kk = multifit(Sarr);
            kk = kk.set_fun (@mftest_gauss, [100,45,10]);
            kk = kk.set_bfun (@mftest_bkgd, {[10,0],[20,0],[30,0]});
            kk = kk.set_options('fit_control_parameters',fcp);
            kk = kk.set_options('listing',nlist);
            [fit.warr, fit.par] = kk.fit;
            
            % Check equality
            if ~self.save_output
                assertEqualToTol (fit, fit_legacy, [1e-6,1e-6])
            end
            assertEqualToTolWithSave (self, fit_legacy, [1e-6,1e-6])
            assertEqualToTolWithSave (self, fit, [1e-6,1e-6])
            
        end
        
        %--------------------------------------------------------------------------
        function test_IX_dataset_1d (self)
            % Test fitting of array of three IX_dataset_1d
            S = self.data;
            warr = [S.w1,S.w2,S.w3];   % array of three datasets
            
            % Ensure fit control parameters are the same for old and new multifit
            fcp = [0.0001 30 0.0001];
            
            % An example fit with old multifit
            nlist = 0;  % set to 0,1 or 2 for increasing verbosity
            [fit_legacy.warr,fit_legacy.par] = multifit (warr,...
                @mftest_gauss, [100,45,10], @mftest_bkgd, {[10,0],[20,0],[30,0]},...
                'fitcontrolparameters',fcp,...
                'list', nlist);
            
            % Same with mfclass
            kk = multifit(warr);
            kk = kk.set_fun (@mftest_gauss, [100,45,10]);
            kk = kk.set_bfun (@mftest_bkgd, {[10,0],[20,0],[30,0]});
            kk = kk.set_options('fit_control_parameters',fcp);
            kk = kk.set_options('listing',nlist);
            [fit.warr, fit.par] = kk.fit;
            
            % Check equality
            if ~self.save_output
                assertEqualToTol (fit, fit_legacy, [1e-6,1e-6])
            end
            assertEqualToTolWithSave (self, fit_legacy, [1e-6,1e-6])
            assertEqualToTolWithSave (self, fit, [1e-6,1e-6])
            
        end
        
        %--------------------------------------------------------------------------
    end
    
end
