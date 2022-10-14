classdef test_smooth < TestCase

    properties
        sqw_file_1d_name = 'sqw_1d_1.sqw';
        sqw_file_2d_name = 'sqw_2d_1.sqw';
        sqw_file_4d_name = 'sqw_4d.sqw';
        sqw_files_path = '../common_data/';

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
            s.pix = PixelDataBase.create();

            d = s.smooth(10, 'hat');
            assertTrue(isa(d, 'sqw'));
        end

        function test_smooth_no_args(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s.pix = PixelDataBase.create();

            d = s.smooth();

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_scalar_width_arg(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s.pix = PixelDataBase.create();

            d = s.smooth(100, 'gaussian');

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_array_width_arg(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s.pix = PixelDataBase.create();

            d = s.smooth([100, 25], 'gaussian');

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_resolution_shape_arg(obj)
            skipTest('No valid agruments allowed for ''resolution'' shape call bug #628');
            s = sqw(obj.test_sqw_2d_fullpath);
            s.pix = PixelDataBase.create();

            d = s.smooth([100, 201, 301], 'resolution');

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_hat_shape_arg(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s.pix = PixelDataBase.create();

            d = s.smooth(100, 'hat');

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_gaussian_shape_arg(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s.pix = PixelDataBase.create();

            d = s.smooth(100, 'gaussian');

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_raises_error_with_invalid_shape_arg(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s.pix = PixelDataBase.create();

            actual = assertExceptionThrown( ...
                @() s.smooth(100, 'invalid_shape'), ...
                'HORACE:DnDBase:invalid_argument');
            assertTrue(contains(actual.message, '''invalid_shape'' is not recognised'));
        end

        function test_smooth_raises_error_with_incorrect_dimension_width_arg(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s.pix = PixelDataBase.create();

            actual = assertExceptionThrown( ...
                @() s.smooth([100,200,300,400,500], 'hat'), ...
                'HORACE:DnDBase:invalid_argument');
            assertTrue(contains(actual.message, 'length equal to the dimensions of the dataset'));
        end

        function test_smooth_raises_error_with_sqw_containing_pixel_data(obj)
            s = sqw(obj.test_sqw_2d_fullpath);

            actual = assertExceptionThrown(@()s.smooth(10), ...
                'HORACE:sqw:invalid_argument');
            assertTrue(contains(actual.message, 'No smoothing of sqw data'))
        end

        function test_smooth_raises_error_if_any_sqw_has_pixel_data_array_call(obj)
            % array-case of previvious test
            s = sqw(obj.test_sqw_2d_fullpath);
            s_nopix = copy(s);
            s_nopix.pix = PixelDataBase.create();

            actual = assertExceptionThrown(@() smooth([s_nopix, s, s_nopix], 10), ...
                'HORACE:sqw:invalid_argument');
            assertTrue(contains(actual.message, 'No smoothing of sqw data'))
        end

        function test_smooth_raises_error_with_wrong_dimension_width_arg(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s_nopix = copy(s);
            s_nopix.pix = PixelDataBase.create();

            actual = assertExceptionThrown( ...
                @() s_nopix.smooth([100, 123, 454], 'hat'), ...
                'HORACE:DnDBase:invalid_argument');
            assertTrue(contains(actual.message, 'length equal to the dimensions of the dataset'));
        end

        function test_smooth_raises_error_if_any_sqw_has_pixel_data(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            s_nopix = copy(s);
            s_nopix.pix = PixelDataBase.create();

            actual = assertExceptionThrown( ...
                @() smooth([s_nopix, s, s_nopix], 10), ...
                'HORACE:sqw:invalid_argument');
            assertTrue(contains(actual.message, 'No smoothing of sqw data'));
        end
    end
end
