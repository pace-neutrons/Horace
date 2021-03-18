classdef test_smooth < TestCase

    properties
        sqw_file_1d_name = 'sqw_1d_1.sqw';
        sqw_file_2d_name = 'sqw_2d_1.sqw';
        sqw_file_4d_name = 'sqw_4d.sqw';
        sqw_files_path = '../test_sqw_file/';

        test_sqw_1d_fullpath = '';
        test_sqw_2d_fullpath = '';
        test_sqw_4d_fullpath = '';
    end


    methods
        function obj = test_smooth(~)
            obj = obj@TestCase('test_smooth');
            obj.test_sqw_1d_fullpath = obj.build_fullpath(obj.sqw_file_1d_name);
            obj.test_sqw_2d_fullpath = obj.build_fullpath(obj.sqw_file_2d_name);
            obj.test_sqw_4d_fullpath = obj.build_fullpath(obj.sqw_file_4d_name);
        end


        function fullpath = build_fullpath(obj, testfile_name)
            test_file = java.io.File(pwd(), fullfile(obj.sqw_files_path, testfile_name));
            fullpath = char(test_file.getCanonicalPath());
        end


        %% SMOOTH
        function test_smooth_returns_sqw_object(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s.data.pix = PixelData();

            d = s.smooth(10, 'hat');
            assertTrue(isa(d, 'sqw'));
        end

        function test_smooth_no_args(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s.data.pix = PixelData();

            d = s.smooth();

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_scalar_width_arg(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s.data.pix = PixelData();

            d = s.smooth(100, 'gaussian');

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_array_width_arg(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s.data.pix = PixelData();

            d = s.smooth([100, 25], 'gaussian');

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_resolution_shape_arg(obj)
            skipTest('No valid agruments possible for resolution call #628');
            s = sqw(obj.test_sqw_2d_fullpath);
            s.data.pix = PixelData();

            d = s.smooth([100, 201, 301], 'resolution');

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_hat_shape_arg(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s.data.pix = PixelData();

            d = s.smooth(100, 'hat');

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_gaussian_shape_arg(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s.data.pix = PixelData();

            d = s.smooth(100, 'gaussian');

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_raises_error_with_invalid_shape_arg(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s.data.pix = PixelData();

            assertExceptionThrown(@()s.smooth(100, 'not-shape'), 'HORACE:smooth:invalid_arguments');
        end

        function test_smooth_raises_error_with_incorrect_dimension_width_arg(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s.data.pix = PixelData();

            assertExceptionThrown(@()s.smooth([10,10,10,10,10]), 'HORACE:smooth:invalid_arguments');
        end

        function test_smooth_raises_error_with_sqw_containing_pixel_data(obj)
            s = sqw(obj.test_sqw_2d_fullpath);

            assertExceptionThrown(@()s.smooth(10), 'HORACE:smooth:invalid_arguments');
        end

        function test_smooth_raises_error_if_any_sqw_has_pixel_data_array_call(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s_nopix = copy(s);
            s_nopix.data.pix = PixelData();

            assertExceptionThrown(@() smooth([s_nopix, s, s_nopix], 10), 'HORACE:smooth:invalid_arguments');
        end


        %% SMOOTH_UNITS
        function test_smooth_units_returns_d2d_object(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s.data.pix = PixelData();

            d = s.smooth_units(10, 'hat');
            assertTrue(isa(d, 'sqw'));
        end

        function test_smooth_units_scalar_width_arg(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s.data.pix = PixelData();

            d = s.smooth_units(100);

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_units_array_width_arg(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s.data.pix = PixelData();

            d = s.smooth_units([100, 25]);

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end


        function test_smooth_units_resolution_shape_arg(obj)
            skipTest('No valid agruments possible for resolution call #628');
            s = sqw(obj.test_sqw_2d_fullpath);
            s.data.pix = PixelData();

            d = s.smooth_units([1, 1.1, 1.2], 'resolution');

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_units_hat_shape_arg(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s.data.pix = PixelData();

            d = s.smooth_units(100, 'hat');

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_units_gaussian_shape_arg(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s.data.pix = PixelData();

            d = s.smooth_units(100, 'gaussian');

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_units_raises_error_with_no_width_arg(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s_nopix = copy(s);
            s_nopix.data.pix = PixelData();

            assertExceptionThrown(@() s_nopix.smooth_units(), 'HORACE:smooth:invalid_arguments');
        end

        function test_smooth_units_raises_error_with_invalid_shape_arg(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s_nopix = copy(s);
            s_nopix.data.pix = PixelData();

            assertExceptionThrown(@() s_nopix.smooth_units(100, 'invalid_shape'), 'HORACE:smooth:invalid_arguments');
        end

        function test_smooth_units_raises_error_with_wrong_dimension_width_arg(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s_nopix = copy(s);
            s_nopix.data.pix = PixelData();

            assertExceptionThrown(@() s_nopix.smooth_units([100, 123], 'invalid_shape'), 'HORACE:smooth:invalid_arguments');
        end

        function test_smooth_units_raises_error_if_any_sqw_has_pixel_data(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s_nopix = copy(s);
            s_nopix.data.pix = PixelData();

            assertExceptionThrown(@() smooth_units([s_nopix, s, s_nopix], 10), 'HORACE:smooth:invalid_arguments');
        end
    end
end
