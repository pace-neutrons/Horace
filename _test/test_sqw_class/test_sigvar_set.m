classdef test_sigvar_set < TestCase

    properties
    end

    methods
        function obj = test_sigvar_set(~)
            obj = obj@TestCase('test_sigvar_set');
        end

        function test_sigvar_set_raises_error_if_s_not_same_size_as_dnd_object(~)
            sqw_obj = sqw();
            sqw_obj.data = d2d( ...
                ortho_axes('nbins_all_dims',[1,3,5,1],'img_range',[-1,-1,-1,-1;1,1,1,1]), ...
                ortho_proj('alatt',3,'angdeg',90));

            sqw_obj.data.s = zeros(3, 5);
            sqw_obj.data.e = zeros(3,5);

            sigvar_obj = sigvar(struct('s', [1, 2, 3], 'e', [44, 55, 66]));

            ME = assertExceptionThrown(@()sigvar_set(sqw_obj,sigvar_obj),...
                'HORACE:DnDBase:invalid_argument');
            assertTrue(contains(ME.message, 'size'));
            assertTrue(contains(ME.message, num2str(size(sqw_obj.data.e))));
            
        end

        function test_sigvar_set_raises_error_if_e_not_same_size_as_dnd_object(~)
            sqw_obj = sqw();
            sqw_obj.data = d2d( ...
                ortho_axes('nbins_all_dims',[3,5,1,1],'img_range',[-1,-1,-1,-1;1,1,1,1]), ...
                ortho_proj('alatt',3,'angdeg',90));

            sqw_obj.data.s = zeros(3,5);
            sqw_obj.data.e = zeros(3,5);
            sigvar_obj = sigvar(struct('s', [1, 2, 3], 'e', [44, 55, 66]));

            ME = assertExceptionThrown(@()sigvar_set(sqw_obj,sigvar_obj),...
                'HORACE:DnDBase:invalid_argument');

            assertTrue(contains(ME.message, 'size'));
            assertTrue(contains(ME.message, num2str(size(sqw_obj.data.e))));

        end

        function test_sigvar_set_updates_s_and_e_values(~)
            sqw_obj = sqw();
            sqw_obj.data = d2d( ...
                ortho_axes('nbins_all_dims',[2,3,1,1],'img_range',[-1,-1,-1,-1;1,1,1,1]), ...
                ortho_proj('alatt',3,'angdeg',90));

            sqw_obj.data.s = zeros(2,3);
            sqw_obj.data.e = zeros(2,3);
            sqw_obj.data.npix = ones(2,3);

            sigvar_obj = sigvar(struct(...
                's', [1, 2, 3; 4, 5, 6], ...
                'e', [44, 55, 66; 77, 88, 99]));

            result = sqw_obj.sigvar_set(sigvar_obj);
            assertEqualToTol(result.data.s, sigvar_obj.s);
            assertEqualToTol(result.data.e, sigvar_obj.e);
        end

        function test_sigvar_set_sets_pixel_data_as_npix_replica_of_image(~)
            sqw_obj = sqw();
            sqw_obj.data = d1d( ...
                ortho_axes('nbins_all_dims',[1,3,1,1],'img_range',[-1,-1,-1,-1;1,1,1,1]), ...
                ortho_proj('alatt',3,'angdeg',90));

            sqw_obj.data.s = zeros(1,3);
            sqw_obj.data.e = zeros(1,3);
            sqw_obj.data.npix = [3, 5, 1];
            sqw_obj.pix = PixelDataBase.create(9);

            sigvar_obj = sigvar(struct('s', [1, 2, 3], 'e', [44, 55, 66]));

            expected_signal = [1,1,1, 2,2,2,2,2, 3];
            expected_varince = [44,44,44, 55,55,55,55,55, 66];

            result = sqw_obj.sigvar_set(sigvar_obj);

            assertEqualToTol(result.pix.signal, expected_signal);
            assertEqualToTol(result.pix.variance, expected_varince);
        end

        function test_sigvar_set_zero_s_and_e_where_npix_zero(~)
            sqw_obj = sqw();
            sqw_obj.data = d1d( ...
                ortho_axes('nbins_all_dims',[1,3,1,1],'img_range',[-1,-1,-1,-1;1,1,1,1]), ...
                ortho_proj('alatt',3,'angdeg',90));
            sqw_obj.data.s = zeros(1,3);
            sqw_obj.data.e = zeros(1,3);
            sqw_obj.data.npix = [3, 0, 1];
            sqw_obj.pix = PixelDataBase.create(4);

            sigvar_obj = sigvar(struct('s', [1, 2, 3], 'e', [44, 55, 66]));

            expected_signal = [1,1,1, 3];
            expected_varince = [44,44,44, 66];
            expected_img_s = [1, 0, 3]';
            expected_img_e = [44, 0, 66]';

            result = sqw_obj.sigvar_set(sigvar_obj);

            assertEqualToTol(result.data.s, expected_img_s);
            assertEqualToTol(result.data.e, expected_img_e);

            assertEqualToTol(result.pix.signal, expected_signal);
            assertEqualToTol(result.pix.variance, expected_varince);
        end
    end
end
