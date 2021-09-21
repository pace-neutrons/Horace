classdef test_sigvar_set < TestCase

    properties
    end

    methods
        function obj = test_sigvar_set(~)
            obj = obj@TestCase('test_sigvar_set');
        end

        function test_sigvar_set_raises_error_if_s_not_same_size_as_dnd_object(~)
            sqw_obj = sqw();
            sqw_obj.data.s = zeros(3, 5);
            sqw_obj.data.e = zeros(1,3);
            sigvar_obj = sigvar(struct('s', [1, 2, 3], 'e', [44, 55, 66]));

            try
                sqw_obj.sigvar_set(sigvar_obj);
                assertTrue(false, 'Expected exception not raised');
            catch ME
                assertEqual(ME.identifier, 'SQW:sigvar_set');
                assertTrue(contains(ME.message, 'signal'));
                assertTrue(contains(ME.message, num2str(size(sqw_obj.data.s))));
                assertTrue(contains(ME.message, num2str(size(sigvar_obj.s))));
            end
        end

        function test_sigvar_set_raises_error_if_e_not_same_size_as_dnd_object(~)
            sqw_obj = sqw();
            sqw_obj.data.s = zeros(1,3);
            sqw_obj.data.e = zeros(3, 5);
            sigvar_obj = sigvar(struct('s', [1, 2, 3], 'e', [44, 55, 66]));

            try
                sqw_obj.sigvar_set(sigvar_obj);
                assertTrue(false, 'Expected exception not raised');
            catch ME
                assertEqual(ME.identifier, 'SQW:sigvar_set');
                assertTrue(contains(ME.message, 'variance'));
                assertTrue(contains(ME.message, num2str(size(sqw_obj.data.e))));
                assertTrue(contains(ME.message, num2str(size(sigvar_obj.e))));
            end
        end

        function test_sigvar_set_updates_s_and_e_values(~)
            sqw_obj = sqw();
            sqw_obj.data.s = zeros(2,3);
            sqw_obj.data.e = zeros(2,3);

            sigvar_obj = sigvar(struct(...
                's', [1, 2, 3; 4, 5, 6], ...
                'e', [44, 55, 66; 77, 88, 99]));

            result = sqw_obj.sigvar_set(sigvar_obj);
            assertEqualToTol(result.data.s, sigvar_obj.s);
            assertEqualToTol(result.data.e, sigvar_obj.e);
        end

        function test_sigvar_set_sets_pixel_data_as_npix_replica_of_image(~)
            sqw_obj = sqw();
            sqw_obj.data.s = zeros(1,3);
            sqw_obj.data.e = zeros(1,3);
            sqw_obj.data.npix = [3, 5, 1];
            sqw_obj.data.pix = PixelData(9);

            sigvar_obj = sigvar(struct('s', [1, 2, 3], 'e', [44, 55, 66]));

            expected_signal = [1,1,1, 2,2,2,2,2, 3];
            expected_varince = [44,44,44, 55,55,55,55,55, 66];

            result = sqw_obj.sigvar_set(sigvar_obj);

            assertEqualToTol(result.data.pix.signal, expected_signal);
            assertEqualToTol(result.data.pix.variance, expected_varince);
        end

        function test_sigvar_set_zero_s_and_e_where_npix_zero(~)
            sqw_obj = sqw();
            sqw_obj.data.s = zeros(1,3);
            sqw_obj.data.e = zeros(1,3);
            sqw_obj.data.npix = [3, 0, 1];
            sqw_obj.data.pix = PixelData(4);

            sigvar_obj = sigvar(struct('s', [1, 2, 3], 'e', [44, 55, 66]));

            expected_signal = [1,1,1, 3];
            expected_varince = [44,44,44, 66];
            expected_img_s = [1, 0, 3];
            expected_img_e = [44, 0, 66];

            result = sqw_obj.sigvar_set(sigvar_obj);

            assertEqualToTol(result.data.s, expected_img_s);
            assertEqualToTol(result.data.e, expected_img_e);

            assertEqualToTol(result.data.pix.signal, expected_signal);
            assertEqualToTol(result.data.pix.variance, expected_varince);
        end
    end
end
