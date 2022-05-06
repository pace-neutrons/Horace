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
            %TODO: this should not be necessary
            hc = hor_config;
            dts = hc.get_data_to_store();
            clob = onCleanup(@()set(hc,dts));
            hc.use_mex = 1;

            % we set up the test "random number generator" which is actually
            % a deterministic set of numbers 1:999 repeated. Use factor to make
            % them in range 0:1
            noise_factor = 1/999;
            % We make an sqw object with the a pixel page size smaller than the
            % total pixel size
            pixel_page_size = 1e5;
            sqw_obj1 = sqw(obj.test_sqw_file_full_path, 'pixel_page_size', ...
                pixel_page_size);

            % ensure we're actually paging pixel data
            pix = sqw_obj1.data.pix;
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
            % We make another sqw objectfrom the same file
            sqw_obj2 = read_sqw(obj.test_sqw_file_full_path);
            % and we noisify it
            % - reset pseudorandom number distribution. If this reverted to
            %   standard MATLAB rng, with myrng=any rnd using rng e.g. randn,
            %   then the reset should be done with
            %   rng(0);
            a.reset();
            noisy_obj2 = noisify(sqw_obj2,noise_factor,'random_number_function',myrng);
            %TODO: this is the issue where filebased and memory based
            %objects are inconsistent. See skipTest operator at the end of
            %the test.
            sqw_obj1.main_header.nfiles = sqw_obj2.main_header.nfiles;
            sqw_obj1.experiment_info = sqw_obj2.experiment_info;

            noisy_obj1.main_header.nfiles = noisy_obj2.main_header.nfiles;
            noisy_obj1.experiment_info = noisy_obj2.experiment_info;
            % as the page test whether the 2 paged versions are equal
            assertEqual(sqw_obj1, sqw_obj2, '', 5e-4);
            assertEqual(noisy_obj1, noisy_obj2, '', 5e-4);

            % test noisify updates data
            assertFalse(equal_to_tol(sqw_obj1, noisy_obj1, 5e-4));
            assertFalse(equal_to_tol(sqw_obj2, noisy_obj2, 5e-4));

            % checks that image data is updated
            assertFalse(equal_to_tol(sqw_obj1.data.s, noisy_obj1.data.s, 5e-4));
            assertFalse(equal_to_tol(sqw_obj2.data.s, noisy_obj2.data.s, 5e-4));
            skipTest("TODO: Experiment info and all related stuff in memory sqw has been reduced to contributed files but on file-based objects it has been not")
        end

        function test_noisify_adds_gaussian_noise_to_data_with_given_stddev(obj)
            if ~license('test', 'statistics_toolbox') || ~exist('fitdist', 'file')
                % fitdist requires the statistics toolbox
                return;
            end
            [~, old_rng_state] = seed_rng(0);
            cleanup = onCleanup(@() rng(old_rng_state));

            sqw_obj = sqw(obj.test_sqw_file_full_path);
            % ensure we're not paging pixel data
            pix = sqw_obj.data.pix;
            assertEqual(pix.page_size, pix.num_pixels);

            noise_factor = 0.01;
            noisy_obj = noisify(sqw_obj, noise_factor);

            original_signal = sqw_obj.data.pix.signal;
            noisy_signal = noisy_obj.data.pix.signal;
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

end
