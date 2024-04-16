classdef test_smooth < TestCaseWithSave

    properties
        sqw_file_1d_name = 'sqw_1d_1.sqw';
        sqw_file_2d_name = 'sqw_2d_1.sqw';
        sqw_file_4d_name = 'sqw_4d.sqw';

        test_sqw_1d_fullpath = '';
        test_sqw_2d_fullpath = '';
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
            obj.test_sqw_4d_fullpath = fullfile(pths.test_common, obj.sqw_file_4d_name);
            obj.save();
        end

        %% SMOOTH
        function test_smooth_returns_dnd_object(obj)
            sqw_in = sqw(obj.test_sqw_2d_fullpath);
            sqw_in.pix = PixelDataBase.create();

            result = sqw_in.smooth(10, 'hat');
            assertTrue(isa(result, 'DnDBase'));
        end

        function test_smooth_no_args(obj)
            sqw_in = sqw(obj.test_sqw_2d_fullpath);
            sqw_in.pix = PixelDataBase.create();

            result = sqw_in.smooth();

            assertEqualToTolWithSave(obj, result, 'ignore_str', true, 'tol', 1e-6)
        end

        function test_smooth_scalar_width_arg(obj)
            sqw_in = sqw(obj.test_sqw_2d_fullpath);
            sqw_in.pix = PixelDataBase.create();

            result = sqw_in.smooth(100, 'gaussian');

            assertEqualToTolWithSave(obj, result, 'ignore_str', true, 'tol', 1e-6)
        end

        function test_smooth_array_width_arg(obj)
            sqw_in = sqw(obj.test_sqw_2d_fullpath);
            sqw_in.pix = PixelDataBase.create();

            result = sqw_in.smooth([100, 25], 'gaussian');

            assertEqualToTolWithSave(obj, result, 'ignore_str', true, 'tol', 1e-6)
        end

        function test_smooth_resolution_shape_arg(obj)
            skipTest('No valid agruments allowed for ''resolution'' shape call bug #628');
            sqw_in = sqw(obj.test_sqw_2d_fullpath);
            sqw_in.pix = PixelDataBase.create();

            result = sqw_in.smooth([100, 201, 301], 'resolution');

            assertEqualToTolWithSave(obj, result, 'ignore_str', true, 'tol', 1e-6)
        end

        function test_smooth_hat_shape_arg(obj)
            sqw_in = sqw(obj.test_sqw_2d_fullpath);
            sqw_in.pix = PixelDataBase.create();

            result = sqw_in.smooth(100, 'hat');

            assertEqualToTolWithSave(obj, result, 'ignore_str', true, 'tol', 1e-6)
        end

        function test_smooth_gaussian_shape_arg(obj)
            sqw_in = sqw(obj.test_sqw_2d_fullpath);
            sqw_in.pix = PixelDataBase.create();

            result = sqw_in.smooth(100, 'gaussian');

            assertEqualToTolWithSave(obj, result, 'ignore_str', true, 'tol', 1e-6)
        end

        function test_smooth_raises_error_with_invalid_shape_arg(obj)
            sqw_in = sqw(obj.test_sqw_2d_fullpath);
            sqw_in.pix = PixelDataBase.create();

            actual = assertExceptionThrown( ...
                @() sqw_in.smooth(100, 'invalid_shape'), ...
                'HORACE:DnDBase:invalid_argument');
            assertTrue(contains(actual.message, '''invalid_shape'' is not recognised'));
        end

        function test_smooth_raises_error_with_incorrect_dimension_width_arg(obj)
            sqw_in = sqw(obj.test_sqw_2d_fullpath);
            sqw_in.pix = PixelDataBase.create();

            actual = assertExceptionThrown( ...
                @() sqw_in.smooth([100,200,300,400,500], 'hat'), ...
                'HORACE:DnDBase:invalid_argument');
            assertTrue(contains(actual.message, 'length equal to the dimensions of the dataset'));
        end

        function test_smooth_raises_error_with_wrong_dimension_width_arg(obj)
            sqw_in = sqw(obj.test_sqw_2d_fullpath);
            sqw_in_nopix = copy(sqw_in); % nopix anticipates later depixelation
            sqw_in_nopix.pix = PixelDataBase.create();

            actual = assertExceptionThrown( ...
                @() sqw_in_nopix.smooth([100, 123, 454], 'hat'), ...
                'HORACE:DnDBase:invalid_argument');
            assertTrue(contains(actual.message, 'length equal to the dimensions of the dataset'));
        end
    end
end
