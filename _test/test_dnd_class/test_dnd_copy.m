classdef test_dnd_copy < TestCase

    properties
        sqw_file_2d_name = 'sqw_2d_1.sqw';
        dnd_file_2d_name = 'dnd_2d.sqw';
        test_file_path = '../common_data/';

        test_sqw_2d_fullpath = '';
        test_dnd_2d_fullpath = '';
    end

    methods

        function obj = test_dnd_copy(~)
            obj = obj@TestCase('test_dnd_copy');

            test_sqw_file = java.io.File(pwd(), fullfile(obj.test_file_path, obj.sqw_file_2d_name));
            obj.test_sqw_2d_fullpath = char(test_sqw_file.getCanonicalPath());
            test_dnd_file = java.io.File(pwd(), fullfile(obj.test_file_path, obj.dnd_file_2d_name));
            obj.test_dnd_2d_fullpath = char(test_dnd_file.getCanonicalPath());
        end

        function test_copy_returns_object_with_identical_data(obj)
            d2d_obj = read_horace(obj.test_dnd_2d_fullpath);
            d2d_copy = copy(d2d_obj);

            assertEqualToTol(d2d_copy, d2d_obj);
        end

        function test_sqw_and_d2d_objects_are_not_equal(obj)
            dnd_2d = read_horace(obj.test_dnd_2d_fullpath);
            sqw_2d = sqw(obj.test_sqw_2d_fullpath);
            [ok, mess] = equal_to_tol(dnd_2d, sqw_2d);
            assertFalse(ok);
            assertEqual(mess, 'Objects being compared are not the same type');
        end

        function test_copy_returns_distinct_object(obj)
            d2d_obj = read_horace(obj.test_dnd_2d_fullpath);
            d2d_copy = copy(d2d_obj);

            d2d_copy.s(1:10) = inf;  % data is O(10^5)
            d2d_copy.npix(16,1:10) = 0;
            d2d_copy.label{1} = 'test';

            % changed data is not mirrored in initial
            assertFalse(equal_to_tol(d2d_copy.s, d2d_obj.s));
            assertFalse(equal_to_tol(d2d_copy.npix, d2d_obj.npix));
            assertFalse(equal_to_tol(d2d_copy.label, d2d_obj.label));
        end

    end
end
