classdef test_join < TestCase
    properties
        test_dir = fullfile(fileparts(mfilename('fullpath')), '../');
    end
    methods
        function obj = test_join(~)
            obj = obj@TestCase('test_join');
        end

        function test_split_and_join_returns_same_object_excluding_pixels(obj)
            fpath = fullfile(obj.test_dir, 'test_sqw_file', 'sqw_2d_1.sqw');
            sqw_obj = read_sqw(fpath);
            split_obj = split(sqw_obj);
            reformed_obj = join(split_obj);

            sqw_obj_copy = sqw_obj;
            sqw_obj_copy.data.pix = PixelData();

            assertEqualToTol(sqw_obj_copy, reformed_obj);
        end

        % Test disabled as there is a know bug with the returned pixeldata (#531)
        function test_split_and_join_returns_same_object_including_pixels(obj)
            skipTest('There is a known bug with the returned pixeldata (#531)');

            fpath = fullfile(obj.test_dir, 'test_sqw_file', 'sqw_2d_1.sqw');
            sqw_obj = read_sqw(fpath);
            split_obj = split(sqw_obj);
            reformed_obj = join(split_obj);

            assertEqualToTol(sqw_obj, reformed_obj);
        end
    end
end
