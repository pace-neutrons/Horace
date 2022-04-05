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
            assertFalse(equal_to_tol(sqw_copy.main_header, sqw_obj.main_header));
            
            % want to test expinfo/instruments and expinfo/detpar
            % separately, so make 2 copies of expinfo
            expinf1 = sqw_copy.experiment_info;
            expinf2 = sqw_copy.experiment_info;

            % all instruments changed with new name to make expinf different
            for i=1:numel(expinf1.instruments), expinf1.instruments{i}.name = 'copy'; end
            sqw_copy = sqw_copy.change_header(expinf1);
            assertFalse(equal_to_tol(sqw_copy.experiment_info, sqw_obj.experiment_info));

            % all detpar detectors changed with new azim value to make expinf different
            for i=1:numel(expinf2.detector_arrays), expinf2.detector_arrays(i).azim = 0; end
            sqw_copy = sqw_copy.change_header(expinf2);
            assertFalse(equal_to_tol(sqw_copy.my_detpar(), sqw_obj.my_detpar()));
            %{
            % old version of detpar change with separate detpar left for
            % reference to see what was intended
            dtp = sqw_copy.my_detpar();
            dtp.azim(1:10) = 0;
            sqw_copy = sqw_copy.change_detpar(dtp);
            %}
            
            % changed data is not mirrored in initial
            sqw_copy.data.dax = [2, 1];
            sqw_copy.data.pix.signal = 1;
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
            assertEqualToTol(sqw_copy.experiment_info, sqw_obj.experiment_info);
            assertEqualToTol(sqw_copy.my_detpar(), sqw_obj.my_detpar());
        end
    end
end
