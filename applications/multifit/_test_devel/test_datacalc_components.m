classdef test_datacalc_components < TestCaseWithSave2
    % Test multifit and legacy version
    properties
        data    % input data for the test suite
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_datacalc_components (name)
            self@TestCaseWithSave2(name);
            
            datafile = fullfile(fileparts(mfilename('fullpath')),'testdata_multifit_1.mat');
            self.data = load(datafile);
            
            self.save()
        end
        
        %--------------------------------------------------------------------------
        function test_sim (self)
            % Test simulation of array of three IX_dataset_1d
            S = self.data;
            warr = [S.w1,S.w2,S.w3];   % array of three datasets
            
            % Set fit control parameters
            fcp = [0.0001 30 0.0001];
            
            nlist = 0;  % set to 0,1 or 2 for increasing verbosity
            kk = multifit(warr);
            kk = kk.set_fun (@mftest_gauss, [100,45,10]);
            kk = kk.set_bfun (@mftest_bkgd, {[10,0],[20,0],[30,0]});
            kk = kk.set_options('fit_control_parameters',fcp);
            kk = kk.set_options('listing',nlist);

            
            % Perform simulations
            wsim = kk.simulate;
            assertEqualToTolWithSave(self,wsim,[1e-6,1e-6])

            % Simulation with components
            wsim_comp = kk.simulate('comp');
            assertEqualToTolWithSave(self,wsim_comp,[1e-6,1e-6])
            
            if ~self.save_output
                wsum=wsim_comp.sum;
                assertEqualToTol(wsim,wsum)

                wfore=wsim_comp.fore;
                wback=wsim_comp.back;
                wsum_from_comps=wfore+wback;  % sum from fore and back separately
                assertEqualToTol(wsum,wsum_from_comps,[1e-12,1e-12])
            end
            
        end
        
        %--------------------------------------------------------------------------
        function test_fit (self)
            % Test fitting of array of three IX_dataset_1d
            S = self.data;
            warr = [S.w1,S.w2,S.w3];   % array of three datasets
            
            % Set fit control parameters
            fcp = [0.0001 30 0.0001];
            
            nlist = 0;  % set to 0,1 or 2 for increasing verbosity
            kk = multifit(warr);
            kk = kk.set_fun (@mftest_gauss, [100,45,10]);
            kk = kk.set_bfun (@mftest_bkgd, {[10,0],[20,0],[30,0]});
            kk = kk.set_options('fit_control_parameters',fcp);
            kk = kk.set_options('listing',nlist);

            
            % Perform fits
            [wfit,fitdata] = kk.fit;
            assertEqualToTolWithSave(self,wfit,[1e-6,1e-6])
            assertEqualToTolWithSave(self,fitdata,[1e-6,1e-6])

            % Perform fit outputting components
            wfit_comp = kk.fit('comp');
            assertEqualToTolWithSave(self,wfit_comp,[1e-6,1e-6])
            
            if ~self.save_output
                wsum=wfit_comp.sum;
                assertEqualToTol(wfit,wsum)

                wfore=wfit_comp.fore;
                wback=wfit_comp.back;
                wsum_from_comps=wfore+wback;  % sum from fore and back separately
                assertEqualToTol(wsum,wsum_from_comps,[1e-12,1e-12])
            end
            
        end
        
        %--------------------------------------------------------------------------
        function test_par_transfer (self)
            % Test transfer of paramaeters from fit to a simulation
            S = self.data;
            warr = [S.w1,S.w2,S.w3];   % array of three datasets
            
            % Set fit control parameters
            fcp = [0.0001 30 0.0001];
            
            nlist = 0;  % set to 0,1 or 2 for increasing verbosity
            kk = multifit(warr);
            kk = kk.set_fun (@mftest_gauss, [100,45,10]);
            kk = kk.set_bfun (@mftest_bkgd, {[10,0],[20,0],[30,0]});
            kk = kk.set_options('fit_control_parameters',fcp);
            kk = kk.set_options('listing',nlist);

            
            % Perform fits outputting components
            [wfit_comp,fitdata] = kk.fit('comp');
            assertEqualToTolWithSave(self,wfit_comp,[1e-6,1e-6])  
            wsum_ref = wfit_comp.sum;
            wfore_ref = wfit_comp.fore;
            wback_ref = wfit_comp.back;
            
            
            % Check parameter transfer feature
            wdefault = kk.simulate(fitdata);
            wsum = kk.simulate(fitdata,'sum');
            wfore = kk.simulate(fitdata,'fore');
            wback = kk.simulate(fitdata,'back');
            if ~self.save_output
                assertEqual(wsum_ref,wdefault)
                assertEqual(wsum_ref,wsum)
                assertEqual(wfore_ref,wfore)
                assertEqual(wback_ref,wback)
            end
            
        end
        
        %--------------------------------------------------------------------------
    end
    
end
