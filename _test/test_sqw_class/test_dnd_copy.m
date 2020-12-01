classdef test_dnd_copy < TestCase

    properties
        sqw_file_1d_name = 'dnd_2d.sqw';
        sqw_files_path = '../test_sqw_file/';

        test_dnd_2d_fullpath = '';
    end

    methods

        function obj = test_dnd_copy(~)
            obj = obj@TestCase('test_dnd_copy');

            test_dnd_file = java.io.File(pwd(), fullfile(obj.sqw_files_path, obj.sqw_file_1d_name));
            obj.test_dnd_2d_fullpath = char(test_dnd_file.getCanonicalPath());
        end

        function test_copy_returns_object_with_identical_data(obj)
            d2d_obj = d2d(obj.test_dnd_2d_fullpath);
            d2d_copy = copy(d2d_obj);

            assertEqualToTol(d2d_copy, d2d_obj);
        end

        function test_copy_returns_distinct_object(obj)
            d2d_obj = d2d(obj.test_dnd_2d_fullpath);
            d2d_copy = copy(d2d_obj);

            d2d_copy.s(1:10) = 1e1000;
            d2d_copy.e = [];
            d2d_copy.ulabel = {'test'};

            % changed data is not mirrored in initial
            assertFalse(equal_to_tol(d2d_copy.s, d2d_obj.s));
            assertFalse(equal_to_tol(d2d_copy.e, d2d_obj.e));
            assertFalse(equal_to_tol(d2d_copy.ulabel, d2d_obj.ulabel));
        end

    end
end
