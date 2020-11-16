classdef test_sqw_copy < TestCase
    
    properties
        sqw_file_1d_name = 'sqw_1d_1.sqw';
        sqw_files_path = '../test_sqw_file/';
        
        test_sqw_1d_fullpath = '';
    end
    
    methods
        
        function obj = test_sqw_copy(~)
            obj = obj@TestCase('test_sqw_copy');
            
            test_sqw_file = java.io.File(pwd(), fullfile(obj.sqw_files_path, obj.sqw_file_1d_name));
            obj.test_sqw_1d_fullpath = char(test_sqw_file.getCanonicalPath());
        end
        
        function test_copy_returns_object_with_identical_data(obj)
            sqw_obj = sqw(obj.test_sqw_1d_fullpath);
            sqw_copy = copy(sqw_obj);
            
            assertEqualToTol(sqw_copy, sqw_obj);
        end
        
        function test_copy_returns_distinct_object(obj)
            sqw_obj = sqw(obj.test_sqw_1d_fullpath);
            sqw_copy = copy(sqw_obj);
            
            sqw_copy.main_header.title = 'test_copy';
            sqw_copy.header = struct([]);
            sqw_copy.detpar.azim(1:10) = 0;
            sqw_copy.data.dax = [2, 1];
            sqw_copy.data.pix.signal = 1;
            
            % changed data is not mirrored in initial
            assertFalse(equal_to_tol(sqw_copy.main_header, sqw_obj.main_header));
            assertFalse(equal_to_tol(sqw_copy.header, sqw_obj.header));
            assertFalse(equal_to_tol(sqw_copy.detpar, sqw_obj.detpar));
            assertFalse(equal_to_tol(sqw_copy.data, sqw_obj.data));
            assertFalse(equal_to_tol(sqw_copy.data.pix, sqw_obj.data.pix));
        end
        
        function test_copy_excluding_pix_returns_empty_pix_data(obj)
            sqw_obj = sqw(obj.test_sqw_1d_fullpath);
            sqw_copy = copy(sqw_obj, 'exclude_pix', true);
            
            % PixelData is not copied
            assertEqual(sqw_copy.data.pix, PixelData());
            
            % confirm selected other data is copied
            assertEqual(sqw_copy.main_header.title, sqw_obj.main_header.title);
            assertEqualToTol(sqw_copy.header, sqw_obj.header);
            assertEqualToTol(sqw_copy.detpar, sqw_obj.detpar);
        end
    end
end
