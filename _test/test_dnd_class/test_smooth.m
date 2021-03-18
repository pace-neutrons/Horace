classdef test_smooth < TestCase
    properties
        sqw_file_2d_name = 'sqw_2d_1.sqw';
        sqw_files_path = '../test_sqw_file/';

        test_sqw_2d_fullpath = '';
    end


    methods
        function obj = test_smooth(~)
            obj = obj@TestCase('test_smooth');
            obj.test_sqw_2d_fullpath = obj.build_fullpath(obj.sqw_file_2d_name);
        end
        function fullpath = build_fullpath(obj, testfile_name)
            test_file = java.io.File(pwd(), fullfile(obj.sqw_files_path, testfile_name));
            fullpath = char(test_file.getCanonicalPath());
        end

        %% SMOOTH
        function test_smooth_returns_dnd_object(obj)
            s = d2d(obj.test_sqw_2d_fullpath);

            d = s.smooth(10, 'hat');
            assertTrue(isa(d, 'd2d'));
        end

        function test_smooth_no_args(obj)
            s = d2d(obj.test_sqw_2d_fullpath);

            d = s.smooth();

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_scalar_width_arg(obj)
            s = d2d(obj.test_sqw_2d_fullpath);

            d = s.smooth(100, 'gaussian');

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_array_width_arg(obj)
            s = d2d(obj.test_sqw_2d_fullpath);

            d = s.smooth([100, 25], 'gaussian');

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_resolution_shape_arg(obj)
            skipTest('No valid agruments possible for resolution call #628');
            s = d2d(obj.test_sqw_2d_fullpath);

            d = s.smooth([100, 201, 301], 'resolution');

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_hat_shape_arg(obj)
            s = d2d(obj.test_sqw_2d_fullpath);

            d = s.smooth(100, 'hat');

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_gaussian_shape_arg(obj)
            s = d2d(obj.test_sqw_2d_fullpath);

            d = s.smooth(100, 'gaussian');

            % TODO: assert data matches expected...
            %assertEqualToTol(d.data.s, expected.data.s, 1e-8);
            %assertEqualToTol(d.data.e, expected.data.e, 1e-8);
        end

        function test_smooth_raises_error_with_invalid_shape_arg(obj)
            s = d2d(obj.test_sqw_2d_fullpath);

            assertExceptionThrown(@()s.smooth(100, 'not-shape'), 'HORACE:smooth:invalid_arguments');
        end

        function test_smooth_raises_error_with_incorrect_dimension_width_arg(obj)
            s = d2d(obj.test_sqw_2d_fullpath);

            assertExceptionThrown(@()s.smooth([10,10,10,10,10]), 'HORACE:smooth:invalid_arguments');
        end

        %% SMOOTH_UNITS
        function test_smooth_units_returns_d2d_object(obj)
            s = d2d(obj.test_sqw_2d_fullpath);

            d = s.smooth_units(10, 'hat');
            assertTrue(isa(d, 'd2d'));
        end

        function test_smooth_units_scalar_width_arg(obj)
            s = d2d(obj.test_sqw_2d_fullpath);

            d = s.smooth_units(100);

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
            s = d2d(obj.test_sqw_2d_fullpath);

            assertExceptionThrown(@() s.smooth_units(), 'HORACE:smooth:invalid_arguments');
        end

        function test_smooth_units_raises_error_with_invalid_shape_arg(obj)
            s = d2d(obj.test_sqw_2d_fullpath);

            assertExceptionThrown(@() s.smooth_units(100, 'invalid_shape'), 'HORACE:smooth:invalid_arguments');
        end

        function test_smooth_units_raises_error_with_wrong_dimension_width_arg(obj)
            s = d2d(obj.test_sqw_2d_fullpath);

            assertExceptionThrown(@() s.smooth_units([100, 123], 'invalid_shape'), 'HORACE:smooth:invalid_arguments');
        end

    end
end
