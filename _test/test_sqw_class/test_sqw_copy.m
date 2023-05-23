classdef test_sqw_copy < TestCase

    properties
        test_sqw_1d_fullpath;
    end

    methods

        function obj = test_sqw_copy(~)
            obj = obj@TestCase('test_sqw_copy');

            pths = horace_paths;
            obj.test_sqw_1d_fullpath = fullfile(pths.test_common, 'sqw_1d_1.sqw');
        end

        function test_copy_returns_object_with_identical_data(obj)
            sqw_obj = sqw(obj.test_sqw_1d_fullpath);
            sqw_copy = copy(sqw_obj);

            assertEqualToTol(sqw_copy, sqw_obj);
        end

        function test_copy_returns_distinct_object(obj)
            sqw_obj = sqw(obj.test_sqw_1d_fullpath);
            sqw_obj.pix = PixelDataMemory(sqw_obj.pix);
            sqw_copy = sqw(sqw_obj);

            sqw_copy.main_header.title = 'test_copy';
            dtp = sqw_copy.detpar();
            dtp.azim(1:10) = 0;
            sqw_copy = sqw_copy.change_detpar(dtp);
            sqw_copy.pix.signal = 1;
            sqw_copy.data.s(1) = 100;

            % changed data is not mirrored in initial
            assertFalse(equal_to_tol(sqw_copy.main_header, sqw_obj.main_header));
%             assertFalse(equal_to_tol(sqw_copy.experiment_info, sqw_obj.experiment_info));
            assertFalse(equal_to_tol(sqw_copy.detpar(), sqw_obj.detpar()));
            assertFalse(equal_to_tol(sqw_copy.data, sqw_obj.data));
            assertFalse(equal_to_tol(sqw_copy.pix, sqw_obj.pix));
        end

        function test_copy_excluding_pix_returns_empty_pix_data(obj)
            sqw_obj = sqw(obj.test_sqw_1d_fullpath);
            sqw_copy = copy(sqw_obj, 'exclude_pix', true);

            % PixelData is not copied
            assertEqual(sqw_copy.pix, PixelDataBase.create());

            % confirm selected other data is copied
            assertEqual(sqw_copy.main_header.title, sqw_obj.main_header.title);
            assertEqualToTol(sqw_copy.experiment_info, sqw_obj.experiment_info);
            assertEqualToTol(sqw_copy.detpar(), sqw_obj.detpar());
        end
    end
end
