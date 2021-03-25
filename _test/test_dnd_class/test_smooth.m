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
        function test_smooth_d1d_returns_d1d_object(obj)
            d1d_obj = d1d(obj.test_sqw_1d_fullpath);

            d = d1d_obj.smooth(10, 'hat');
            assertTrue(isa(d, 'd1d'));
        end
        function test_smooth_d2d_returns_d2d_object(obj)
            d2d_obj = d2d(obj.test_sqw_2d_fullpath);

            d = d2d_obj.smooth(10, 'hat');
            assertTrue(isa(d, 'd2d'));
        end
        function test_smooth_d3d_returns_d3d_object(obj)
            skipTest('No d3d test data');
            d3d_obj = d3d(obj.test_sqw_3d_fullpath);

            d = d3d_obj.smooth(10, 'hat');
            assertTrue(isa(d, 'd3d'));
        end
        function test_smooth_d4d_returns_d4d_object(obj)
            d4d_obj = d4d(obj.test_sqw_4d_fullpath);

            d = d4d_obj.smooth(10, 'hat');
            assertTrue(isa(d, 'd4d'));
        end

        function test_smooth_no_args(obj)
            d2d_obj = d2d(obj.test_sqw_2d_fullpath);

            d = d2d_obj.smooth();

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_scalar_width_arg(obj)
            d2d_obj = d2d(obj.test_sqw_2d_fullpath);

            d = d2d_obj.smooth(100);

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_array_width_arg(obj)
            d2d_obj = d2d(obj.test_sqw_2d_fullpath);

            d = d2d_obj.smooth([100, 25]);

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_resolution_shape_arg(obj)
            skipTest('No valid agruments allowed for ''resolution'' shape call bug #628');
            d2d_obj = d2d(obj.test_sqw_2d_fullpath);

            d = d2d_obj.smooth([100, 201, 301], 'resolution');

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_hat_shape_arg(obj)
            d2d_obj = d2d(obj.test_sqw_2d_fullpath);

            d = d2d_obj.smooth(100, 'hat');

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_gaussian_shape_arg(obj)
            d2d_obj = d2d(obj.test_sqw_2d_fullpath);

            d = d2d_obj.smooth(100, 'gaussian');

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_raises_error_with_invalid_shape_arg(obj)
            d2d_obj = d2d(obj.test_sqw_2d_fullpath);

            actual = assertExceptionThrown( ...
                @() d2d_obj.smooth(100, 'invalid_shape'), ...
                'HORACE:smooth:invalid_arguments');
            assertTrue(contains(actual.message, '''invalid_shape'' is not recognised'));

        end

        function test_smooth_raises_error_with_incorrect_dimension_width_arg(obj)
            d2d_obj = d2d(obj.test_sqw_2d_fullpath);

            actual = assertExceptionThrown(@() d2d_obj.smooth([10,10,10,10,10]), ...
                'HORACE:smooth:invalid_arguments');
            assertTrue(contains(actual.message, 'length equal to the dimensions of the dataset'))
        end

        %% SMOOTH_UNITS
        function test_smooth_units_returns_d2d_object(obj)
            s = d2d(obj.test_sqw_2d_fullpath);

            d = s.smooth_units(10, 'hat');
            assertTrue(isa(d, 'd2d'));
        end

        function test_smooth_units_d1d_scalar_width_arg(obj)
            s = d1d(obj.test_sqw_1d_fullpath);

            d = s.smooth_units(100);

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end
        function test_smooth_units_d2d_scalar_width_arg(obj)
            s = d2d(obj.test_sqw_2d_fullpath);

            d = s.smooth_units(100);

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end
        function test_smooth_units_d4d_scalar_width_arg(obj)
            s = d4d(obj.test_sqw_4d_fullpath);

            d = s.smooth_units(1); % smaller scale used here to prevent array allocation overflow

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_units_array_width_arg(obj)
            s = d2d(obj.test_sqw_2d_fullpath);

            d = s.smooth_units([100, 25]);

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end


        function test_smooth_units_resolution_shape_arg(obj)
            skipTest('No valid agruments possible for resolution call #628');
            s = d2d(obj.test_sqw_2d_fullpath);

            d = s.smooth_units([1, 1.1, 1.2], 'resolution');

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_units_hat_shape_arg(obj)
            s = d2d(obj.test_sqw_2d_fullpath);

            d = s.smooth_units(100, 'hat');

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_units_gaussian_shape_arg(obj)
            s = d2d(obj.test_sqw_2d_fullpath);

            d = s.smooth_units(100, 'gaussian');

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_units_raises_error_with_no_width_arg(obj)
            d2d_obj = d2d(obj.test_sqw_2d_fullpath);

            actual = assertExceptionThrown(@() d2d_obj.smooth_units(), ...
                'HORACE:smooth:invalid_arguments');

            assertTrue(contains(actual.message, 'Must give smoothing parameter(s)'));
        end

        function test_smooth_units_raises_error_with_invalid_shape_arg(obj)
            d2d_obj = d2d(obj.test_sqw_2d_fullpath);

            actual = assertExceptionThrown( ...
                @() d2d_obj.smooth_units(100, 'invalid_shape'), ...
                'HORACE:smooth:invalid_arguments');
            assertTrue(contains(actual.message, '''invalid_shape'' is not recognised'));
        end

        function test_smooth_units_raises_error_with_wrong_dimension_width_arg(obj)
            d2d_obj = d2d(obj.test_sqw_2d_fullpath);

            actual = assertExceptionThrown( ...
                @() d2d_obj.smooth_units([100,200,300,400,500], 'hat'), ...
                'HORACE:smooth:invalid_arguments');
            assertTrue(contains(actual.message, 'length equal to the dimensions of the dataset'))
        end

    end
end
