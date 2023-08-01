classdef test_sampling_statistics < TestCase
    % Test the calculation of quantities for IX_det_He3tube object
    properties
        mean_ref
        cov_ref
        
        seed
        rng_state
    end
    
    methods
        %--------------------------------------------------------------------------
        function obj = test_sampling_statistics (name)
            obj = obj@TestCase(name);
            
            % Mean and covariance for multivariate Gaussian
            obj.mean_ref = [2;4;5];
            obj.cov_ref = [...
                4,2,3;
                2,7,5;
                3,5,6];
            
            % Random number seed
            % ------------------
            obj.seed = 0;
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
        function test_stderr_estimates (obj)
            % Generate nloop sets of npnt samples. For each sample, use the
            % function sampling_statistics.m to return the mean, standard error
            % and covariance, and the estimated standard errors on those quantities.
            % The output is then validated by computing the standard errors on
            % the mean, standard error and covariance across the nloop datasets
            % and checking that those standard errors agree with the mean of the
            % standard errors returned by sampling_statistics.m
            
            nloop = 1000;
            npnt = 1000;
            
            mean_val = NaN([nloop,3]);
            sig_mean = NaN([nloop,3]);
            sig_val = NaN([nloop,3]);
            sig_sig = NaN([nloop,3]);
            cov_val = NaN([nloop,3,3]);
            sig_cov = NaN([nloop,3,3]);
            for i=1:nloop
                X = rand_mvgauss(obj.mean_ref, obj.cov_ref, npnt)';
                [mean_val(i,:), sig_mean(i,:), sig_val(i,:), sig_sig(i,:),...
                    cov_val(i,:,:), sig_cov(i,:,:)] = ...
                    sampling_statistics (X);
            end
            
            % The mean value of sig_mean should match the standard error of the
            % distribution of mean values across the nloop sets. The criterion
            % for determining 'equality' must allow the statistical uncertainty
            % of the estimates... we have nloop sets
            
            stderr_of_mean_val = std(mean_val,1);   % experimental std_err
            mean_of_sig_mean = mean(sig_mean, 1);   % computed std_err
            
            stderr_of_sig_val = std(sig_val,1);     % experimental std_err
            mean_of_sig_sig = mean(sig_sig, 1);     % computed std_err
            
            cov_val_flatten = reshape(cov_val,nloop,9);
            stderr_of_cov_val = std(cov_val_flatten,1);     % experimental std_err
            stderr_of_cov_val = reshape(stderr_of_cov_val, [3,3]);
            
            sig_cov_flatten = reshape(sig_cov,nloop,9);
            mean_of_sig_cov = mean(sig_cov_flatten, 1);     % computed std_err
            mean_of_sig_cov = reshape(mean_of_sig_cov, [3,3]);
            
            % Validate standard error estimates
            ntol = 3;
            reltol = ntol/sqrt(nloop);
            assertEqualToTol(stderr_of_mean_val, mean_of_sig_mean, 'reltol', reltol)
            assertEqualToTol(stderr_of_sig_val, mean_of_sig_sig, 'reltol', reltol)
            assertEqualToTol(stderr_of_cov_val, mean_of_sig_cov, 'reltol', reltol)
            
        end
        
        function test_val_estimates (obj)
            % Compute mean, sig and cov and compare with reference values
            npnt = 1e6;
            X = rand_mvgauss(obj.mean_ref, obj.cov_ref, npnt)';
            [mean_val, sig_mean, sig_val, sig_sig, cov_val, sig_cov, minval, maxval] = ...
                sampling_statistics (X);
            
            ntol = 3;   % acceptable multiple of estimated errors
            assertTrue(all(abs(mean_val - obj.mean_ref') < ntol*sig_mean), ...
                'Difference of mean outside tolerance')
            assertTrue(all(abs(sig_val - sqrt(diag(obj.cov_ref)')) < ntol*sig_sig), ...
                'Difference of sigma outside tolerance')
            assertTrue(all(abs(cov_val(:) - obj.cov_ref(:)) < ntol*sig_cov(:)), ...
                'Difference of covariance outside tolerance')
            assertEqual(minval, min(X, [], 1))
            assertEqual(maxval, max(X, [], 1))
        end
        
        
        %--------------------------------------------------------------------------
    end
    
end
