classdef test_smooth < TestCaseWithSave
    properties
        sqw_file_1d_name = 'sqw_1d_1.sqw';
        sqw_file_2d_name = 'sqw_2d_1.sqw';
        sqw_file_3d_name = 'w3d_d3d.sqw'
        sqw_file_4d_name = 'sqw_4d.sqw';

        test_sqw_1d_fullpath = '';
        test_sqw_2d_fullpath = '';
        test_sqw_3d_fullpath = '';
        test_sqw_4d_fullpath = '';
    end


    methods
        function obj = test_smooth(varargin)
            if nargin == 0
                argi = {'test_smooth'};
            else
                argi = {varargin{1}, 'test_smooth'};
            end
            obj = obj@TestCaseWithSave(argi{:});

            pths = horace_paths();

            obj.test_sqw_1d_fullpath = fullfile(pths.test_common, obj.sqw_file_1d_name);
            obj.test_sqw_2d_fullpath = fullfile(pths.test_common, obj.sqw_file_2d_name);
            obj.test_sqw_3d_fullpath = fullfile(pths.test_common, obj.sqw_file_3d_name);
            obj.test_sqw_4d_fullpath = fullfile(pths.test_common, obj.sqw_file_4d_name);
            obj.save();
        end

        %% SMOOTH
        function test_smooth_sqw1d_returns_sqw1d_object(obj)
            sqw_obj_dnd_type = read_dnd(obj.test_sqw_1d_fullpath);

            d = sqw_obj_dnd_type.smooth(10, 'hat');
            assertTrue(isa(d, 'd1d'));
        end

        function test_smooth_d2d_returns_d2d_object(obj)
            d2d_obj = read_dnd(obj.test_sqw_2d_fullpath);

            d = d2d_obj.smooth(10, 'hat');
            assertTrue(isa(d, 'd2d'));
        end

        function test_smooth_d3d_returns_d3d_object(obj)
            d3d_obj = read_dnd(obj.test_sqw_3d_fullpath);

            d = d3d_obj.smooth(10, 'hat');
            assertTrue(isa(d, 'd3d'));
        end

        function test_smooth_sqwd4d_returns_dndd4d_object(obj)
            clWr = set_temporary_warning('off', 'HORACE:old_file_format');
            sqw4d_obj = read_sqw(obj.test_sqw_4d_fullpath);
            sqw4d_obj.pix = [];

            d = sqw4d_obj.smooth(10, 'hat');
            assertTrue(isa(d, 'd4d'));
            assertFalse(d.has_pixels());
        end

        function test_smooth_no_args(obj)
            d2d_obj = read_dnd(obj.test_sqw_2d_fullpath);

            d2d_smooth = d2d_obj.smooth();

            assertEqualToTolWithSave(obj, d2d_smooth, 'ignore_str', true)
        end

        function test_smooth_scalar_width_arg(obj)
            d2d_obj = read_dnd(obj.test_sqw_2d_fullpath);

            d2d_smooth100 = d2d_obj.smooth(100);

            assertEqualToTolWithSave(obj, d2d_smooth100, 'ignore_str', true)
        end

        function test_smooth_array_width_arg(obj)
            d2d_obj = read_dnd(obj.test_sqw_2d_fullpath);

            d2d_smooth_100_25 = d2d_obj.smooth([100, 25]);
            assertEqualToTolWithSave(obj, d2d_smooth_100_25, 'ignore_str', true)
        end

        function test_smooth_resolution_shape_arg(obj)
            skipTest('No valid arguments for ''resolution'' shape call bug #628');
            d2d_obj = d2d(obj.test_sqw_2d_fullpath);

            d = d2d_obj.smooth([100, 201, 301], 'resolution');

            % TODO: assert data matches expected...
            assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_hat_shape_arg(obj)
            d2d_obj = read_dnd(obj.test_sqw_2d_fullpath);

            d2d_smoorh100_hat = d2d_obj.smooth(100, 'hat');
            assertEqualToTolWithSave(obj, d2d_smoorh100_hat, 'ignore_str', true)

        end

        function test_smooth_gaussian_shape_arg(obj)
            d2d_obj = read_dnd(obj.test_sqw_2d_fullpath);

            d2d_smoorh100_gaus = d2d_obj.smooth(100, 'gaussian');

            assertEqualToTolWithSave(obj, d2d_smoorh100_gaus, 1.e-7, 'ignore_str', true)
        end

        function test_smooth_raises_error_with_invalid_shape_arg(obj)
            d2d_obj = read_dnd(obj.test_sqw_2d_fullpath);

            actual = assertExceptionThrown( ...
                @() d2d_obj.smooth(100, 'invalid_shape'), ...
                'HORACE:DnDBase:invalid_argument');
            assertTrue(contains(actual.message, '''invalid_shape'' is not recognised'));

        end

        function test_smooth_raises_error_with_incorrect_dimension_width_arg(obj)
            d2d_obj = read_dnd(obj.test_sqw_2d_fullpath);

            actual = assertExceptionThrown(@() d2d_obj.smooth([10, 10, 10, 10, 10]), ...
                'HORACE:DnDBase:invalid_argument');
            assertTrue(contains(actual.message, 'length equal to the dimensions of the dataset'))
        end
    end
end
