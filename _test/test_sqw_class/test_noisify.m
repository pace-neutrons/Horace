classdef test_noisify < TestCase & common_sqw_class_state_holder

    properties

        test_sqw_file_path = '../test_sqw_file/deterministic_sqw_fake_data_for_testing.sqw';
        test_sqw_file_full_path = '';
    end

    methods

        function obj = test_noisify(~)
            obj = obj@TestCase('test_noisify');

            % Process the file path
            test_sqw_file = java.io.File(pwd(), obj.test_sqw_file_path);
            obj.test_sqw_file_full_path = char(test_sqw_file.getCanonicalPath());

        end

        function test_noisify_returns_equivalent_sqw_for_paged_pixel_data(obj)
            clob = set_temporary_config_options(hor_config, ...
                'use_mex', 1, ...
                'mem_chunk_size', floor(100337/5), ... % 5 or 6 pages
                'fb_scale_factor', 3 ...
                );

            % we set up the test "random number generator" which is actually
            % a deterministic set of numbers 1:999 repeated. Use factor to make
            % them in range 0:1
            noise_factor = 1/999;

            sqw_obj1 = sqw(obj.test_sqw_file_full_path,'file_backed',true);

            % ensure we're actually paging pixel data
            pix = sqw_obj1.pix;
            assertTrue(pix.num_pixels > pix.page_size);

            % and we noisify it
            % here using a regular sequence (disguised as pseudorandom)
            % to make testing by eye easier:
            a=deterministic_pseudorandom_sequence();
            myrng=@a.myrand;

            % if the standard MATLAB rng were used then we would need to
            % initialise that to a repeatable state by:
            % rng(0)

            % add the noise to object 1 using myrng (myrng could be left out
            % to get the default randn behaviour, used with rng(0)
            noisy_obj1 = noisify(sqw_obj1,noise_factor,'random_number_function',myrng);

            % step 2 load sqw object to memory
            % We make another sqw object from the same file
            sqw_obj2 = read_sqw(obj.test_sqw_file_full_path);
            % and we noisify it
            % - reset pseudorandom number distribution. If this reverted to
            %   standard MATLAB rng, with myrng=any rnd using rng e.g. randn,
            %   then the reset should be done with
            %   rng(0);
            a.reset();
            noisy_obj2 = noisify(sqw_obj2,noise_factor,'random_number_function',myrng);
            assertEqualToTol(sqw_obj1,sqw_obj2, ...
                'tol',[5.e-4,5.e-4],'ignore_str',true,'-ignore_date')
            assertEqualToTol(noisy_obj1,noisy_obj2, ...
                'tol',[5.e-4,5.e-4],'ignore_str',true,'-ignore_date')

            % test noisify updates data
            assertFalse(equal_to_tol(sqw_obj1, noisy_obj1, 5e-4));
            assertFalse(equal_to_tol(sqw_obj2, noisy_obj2, 5e-4));

            % checks that image data is updated
            assertFalse(equal_to_tol(sqw_obj1.data.s, noisy_obj1.data.s, 5e-4));
            assertFalse(equal_to_tol(sqw_obj2.data.s, noisy_obj2.data.s, 5e-4));
        end

        function test_noisify_adds_gaussian_noise_to_data_with_given_stddev(obj)
            try
                fitdist()
            catch ME
                if strcmp(ME.identifier,'MATLAB:ErrorRecovery:UnlicensedFunction')
                    skipTest('Statistics toolbox not available')
                end
            end

            [~, old_rng_state] = seed_rng(0);
            cleanup = onCleanup(@() rng(old_rng_state));

            sqw_obj = sqw(obj.test_sqw_file_full_path);
            % ensure we're not paging pixel data
            pix = sqw_obj.pix;
            assertEqual(pix.page_size, pix.num_pixels);

            noise_factor = 0.01;
            noisy_obj = noisify(sqw_obj, noise_factor);

            original_signal = sqw_obj.pix.signal;
            noisy_signal = noisy_obj.pix.signal;
            signal_diff = original_signal - noisy_signal;

            % Fit the signal differences and check that the expected mu and sigma
            % for the normal distribution fall within the 95% confidence interval
            % using paramci
            pd = fitdist(signal_diff(:), 'normal');
            mu_interval = paramci(pd, 'parameter', 'mu');
            assertTrue(mu_interval(2) - mu_interval(1) < 2);
            assertTrue((mu_interval(1) <= 0) && (mu_interval(2) >= 0));

            sigma_interval = paramci(pd, 'parameter', 'sigma');
            expected_stddev = noise_factor*max(original_signal);
            assertTrue(sigma_interval(2) - sigma_interval(1) < expected_stddev/10);
            assertTrue((sigma_interval(1) <= expected_stddev) ...
                && (sigma_interval(2) >= expected_stddev));
        end
    end
    %======================================================================
    methods
        function test_npoisify_parser_maxval_frac(~)
            [~,~,outpar] = noisify([],[],0.01,'maximum_value',1);

            assertTrue(isfield(outpar,'driven_mode'));
            assertEqual(outpar.fac,0.01);
            assertFalse(outpar.is_poisson);
            assertEqual(outpar.ymax,1);
            % this not used but still contains defaults
            assertEqual(func2str(outpar.randfunc),'randn');
        end

        function test_npoisify_parser_maxval(~)
            [~,~,outpar] = noisify([],[],'maximum_value',1);

            assertTrue(isfield(outpar,'driven_mode'));
            assertEqual(outpar.fac,0.1);
            assertFalse(outpar.is_poisson);
            assertEqual(outpar.ymax,1);
            % this not used but still contains defaults
            assertEqual(func2str(outpar.randfunc),'randn');
        end

        function test_npoisify_parser_poisson(~)
            [~,~,outpar] = noisify([],[],'poisson');

            assertTrue(isfield(outpar,'driven_mode'));
            assertEqual(outpar.fac,0.1);
            assertTrue(outpar.is_poisson);
            assertEqual(outpar.ymax, -inf);
            % this not used but still contains defaults
            assertEqual(func2str(outpar.randfunc),'randn');
        end

        function test_npoisify_parser_ymax(~)
            [~,~,outpar] = noisify([],[],0.01);

            assertTrue(isfield(outpar,'driven_mode'));
            assertEqual(outpar.fac,0.01);
            assertFalse(outpar.is_poisson);
            assertTrue(isempty(outpar.ymax));
            assertEqual(func2str(outpar.randfunc),'randn');
        end

        function test_npoisify_parser_default(~)
            [~,~,outpar] = noisify([],[]);

            assertTrue(isfield(outpar,'driven_mode'));
            assertEqual(outpar.fac,0.1);
            assertFalse(outpar.is_poisson);
            assertTrue(isempty(outpar.ymax));
            assertEqual(func2str(outpar.randfunc),'randn');
        end

    end
end
