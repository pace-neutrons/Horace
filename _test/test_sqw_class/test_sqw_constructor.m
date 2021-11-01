classdef test_sqw_constructor < TestCase & common_sqw_class_state_holder
    
    properties
        sqw_file_1d_name = 'sqw_1d_1.sqw';
        sqw_files_path = '../test_sqw_file/';
        
        test_sqw_1d_fullpath = '';
        test_dir
        %
    end
    
    methods
        
        function obj = test_sqw_constructor(~)
            obj = obj@TestCase('test_sqw_constructor');
            
            test_sqw_file = java.io.File(pwd(), fullfile(obj.sqw_files_path, obj.sqw_file_1d_name));
            obj.test_sqw_1d_fullpath = char(test_sqw_file.getCanonicalPath());
            obj.test_dir = fileparts(mfilename('fullpath'));
        end
        
        
        function test_sqw_class_follows_expected_class_heirarchy(~)
            sqw_obj = sqw();
            
            assertTrue(isa(sqw_obj, 'sqw'));
            assertTrue(isa(sqw_obj, 'SQWDnDBase'));
        end
        
        function test_default_constructor_returns_empty_instance(~)
            sqw_obj = sqw();
            
            assertTrue(isa(sqw_obj, 'sqw'));
            assertEqual(sqw_obj.main_header, struct([]));
            assertTrue(isa(sqw_obj.experiment_info, 'Experiment'));
            
            assertTrue(isempty(sqw_obj.experiment_info.instruments));
            assertEqual(sqw_obj.detpar, struct([]));
            assertEqual(sqw_obj.data.pix, PixelData());
            assertEqual(numel(sqw_obj.data.pax), 0);
        end
        
        function test_filename_constructor_returns_populated_class(obj)
            sqw_obj = sqw(obj.test_sqw_1d_fullpath);
            
            % expected data populated from instance of test object
            assertTrue(isa(sqw_obj, 'sqw'));
            assertEqual(sqw_obj.main_header.nfiles, 85)
            assertEqual(numel(sqw_obj.experiment_info.expdata), 85)
            assertEqual(numel(sqw_obj.experiment_info.instruments), 85)
            assertEqual(numel(sqw_obj.experiment_info.samples), 85)
            assertEqual(numel(sqw_obj.detpar.group), 36864);
            assertEqual(numel(sqw_obj.data.pax), 1);
            assertEqual(sqw_obj.data.pix.num_pixels, 100337);
        end
        
        function test_filename_constructor_sets_pixel_page_size_if_passed(obj)
            pagesize_pixels = 666; % test value
            pagesize_bytes = pagesize_pixels * PixelData.DATA_POINT_SIZE * PixelData.DEFAULT_NUM_PIX_FIELDS;
            
            sqw_obj = sqw(obj.test_sqw_1d_fullpath, 'pixel_page_size', pagesize_bytes);
            
            assertTrue(isa(sqw_obj, 'sqw'));
            assertTrue(sqw_obj.data.pix.num_pixels > pagesize_pixels);
            assertEqual(sqw_obj.data.pix.num_pixels, 100337); % expected value from test file
            assertEqual(sqw_obj.data.pix.page_size, pagesize_pixels);
        end
        
        function test_filename_constructor_sets_all_data_default_pagesize(obj)
            sqw_obj = sqw(obj.test_sqw_1d_fullpath);
            
            assertTrue(isa(sqw_obj, 'sqw'));
            assertEqual(sqw_obj.data.pix.num_pixels, 100337); % expected value from test file
            assertEqual(sqw_obj.data.pix.page_size, 100337);
        end
        
        function test_copy_constructor_clones_object(obj)
            sqw_obj = sqw(obj.test_sqw_1d_fullpath);
            sqw_copy = sqw(sqw_obj);
            
            assertTrue(isa(sqw_obj, 'sqw'));
            assertEqualToTol(sqw_copy, sqw_obj);
        end
        
        function test_copy_constructor_returns_distinct_object(obj)
            sqw_obj = sqw(obj.test_sqw_1d_fullpath);
            sqw_copy = sqw(sqw_obj);
            
            sqw_copy.main_header.title = 'test_copy';
            sqw_copy = sqw_copy.change_header(Experiment());
            sqw_copy.detpar.azim(1:10) = 0;
            sqw_copy.data.dax = [2 1];
            sqw_copy.data.pix.signal = 1;
            
            % changed data is not mirrored in initial
            assertFalse(equal_to_tol(sqw_copy.main_header, sqw_obj.main_header));
            assertFalse(equal_to_tol(sqw_copy.experiment_info, sqw_obj.experiment_info));
            assertFalse(equal_to_tol(sqw_copy.detpar, sqw_obj.detpar));
            assertFalse(equal_to_tol(sqw_copy.data, sqw_obj.data));
            assertFalse(equal_to_tol(sqw_copy.data.pix, sqw_obj.data.pix));
            
            assertFalse(equal_to_tol(sqw_copy, sqw_obj));
        end
        
        function test_save_load_returns_identical_object(obj)
            tmp_filename=fullfile(tmp_dir, 'sqw_loadobj_test.mat');
            cleanup_obj=onCleanup(@() delete(tmp_filename));
            
            sqw_obj = read_sqw(obj.test_sqw_1d_fullpath);
            save(tmp_filename, 'sqw_obj');
            from_file = load(tmp_filename);
            mat_stored_new = from_file.sqw_obj; % expand variable into full 
            % variable with name to provide assertEqual with the variable
            % name
            assertEqualToTol(mat_stored_new, sqw_obj);
            
            old_file = fullfile(obj.test_dir,'data','sqw_loadobj_test_v3_6_1.mat');
            from_file = load(old_file);
            mat_stored_old = from_file.sqw_obj;
            assertEqualToTol(mat_stored_old, sqw_obj,'ignore_str',true);
        end
    end
end
