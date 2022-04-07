classdef test_PixelData_compute_bin_data < TestCase & common_pix_class_state_holder
    
    properties
        BYTES_PER_PIX = PixelData.DATA_POINT_SIZE*PixelData.DEFAULT_NUM_PIX_FIELDS;
        SIGNAL_IDX = 8;
        VARIANCE_IDX = 9;
        
        ALL_IN_MEM_PG_SIZE = 1e12;
        FLOAT_TOLERANCE = 4.75e-4;
        
        test_sqw_file_path = '../common_data/sqw_1d_1.sqw';
        test_sqw_2d_file_path = '../common_data/sqw_2d_1.sqw';
        ref_npix_data = [];
        ref_s_data = [];
        ref_e_data = [];
        
        pix_with_pages_2d;
        ref_npix_data_2d;
        ref_s_data_2d;
        ref_e_data_2d;
        
        pix_in_memory_base;
        pix_in_memory;
        pix_with_pages_base;
        pix_with_pages;
        
        old_warn_state;
    end
    
    methods
        function obj = test_PixelData_compute_bin_data(name)
            if ~exist('name','var')
                name = 'test_PixelData_compute_bin_data';
            end
            obj = obj@TestCase(name);
            
            % Load a 1D SQW file
            sqw_test_obj = sqw(obj.test_sqw_file_path);
            obj.ref_npix_data = sqw_test_obj.data.npix;
            obj.ref_s_data = sqw_test_obj.data.s;
            obj.ref_e_data = sqw_test_obj.data.e;
            
            num_pix_pages = 6;
            page_size = floor(sqw_test_obj.data.pix.num_pixels/num_pix_pages)*obj.BYTES_PER_PIX;
            obj.pix_in_memory_base = sqw_test_obj.data.pix;
            obj.pix_with_pages_base = PixelData(obj.test_sqw_file_path, page_size);
            
            % Load 2D SQW file
            sqw_2d_test_object = sqw(obj.test_sqw_2d_file_path);
            obj.ref_npix_data_2d = sqw_2d_test_object.data.npix;
            obj.ref_s_data_2d = sqw_2d_test_object.data.s;
            obj.ref_e_data_2d = sqw_2d_test_object.data.e;
            
            num_pix = sqw_2d_test_object.data.pix.num_pixels;
            page_size_2d = floor(num_pix/num_pix_pages)*obj.BYTES_PER_PIX;
            obj.pix_with_pages_2d = PixelData(obj.test_sqw_2d_file_path, page_size_2d);
        end
        
        function setUp(obj)
            obj.pix_in_memory = copy(obj.pix_in_memory_base);
            obj.pix_with_pages = copy(obj.pix_with_pages_base);
        end
        
        function test_correct_output_in_memory_mex_1_thread(obj)
            cleanup_handle = set_temporary_config_options( ...
                hor_config(), ...
                'use_mex', true, ...
                'threads', 1 ...
                );  %#ok  unused variable ok as it's a cleanup object
            
            [s, e] = obj.pix_in_memory.compute_bin_data(obj.ref_npix_data);
            
            assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
            assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
        end
        
        function test_correct_output_in_memory_mex_4_threads(obj)
            cleanup_handle = set_temporary_config_options( ...
                hor_config(), ...
                'use_mex', true, ...
                'threads', 4 ...
                );  %#ok  unused variable ok as it's a cleanup object
            
            [s, e] = obj.pix_in_memory.compute_bin_data(obj.ref_npix_data);
            
            assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
            assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
        end
        
        function test_correct_output_all_data_in_memory_mex_off(obj)
            cleanup_handle = ...
                set_temporary_config_options(hor_config(), 'use_mex', false ...
                );  %#ok  unused variable ok as it's a cleanup object
            
            [s, e] = obj.pix_in_memory.compute_bin_data(obj.ref_npix_data);
            
            assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
            assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
        end
        
        function test_correct_output_file_backed_mex_1_thread(obj)
            cleanup_handle = set_temporary_config_options( ...
                hor_config(), ...
                'use_mex', true, ...
                'threads', 1 ...
                );  %#ok  unused variable ok as it's a cleanup object
            
            [s, e] = obj.pix_with_pages.compute_bin_data(obj.ref_npix_data);
            
            assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
            assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
        end
        
        function test_correct_output_5_pages_mex_1_thread(obj)
            cleanup_handle = set_temporary_config_options( ...
                hor_config(), ...
                'use_mex', true, ...
                'threads', 1 ...
                );  %#ok  unused variable ok as it's a cleanup object
            
            file_info = dir(obj.test_sqw_file_path);
            pg_size = file_info.bytes/5;
            pix = PixelData(obj.test_sqw_file_path, pg_size);
            [s, e] = pix.compute_bin_data(obj.ref_npix_data);
            
            assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
            assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
        end
        
        function test_correct_output_file_backed_mex_4_threads(obj)
            cleanup_handle = set_temporary_config_options( ...
                hor_config(), ...
                'use_mex', true, ...
                'threads', 4 ...
                );  %#ok  unused variable ok as it's a cleanup object
            
            [s, e] = obj.pix_with_pages.compute_bin_data(obj.ref_npix_data);
            
            assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
            assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
        end
        
        function test_file_backed_2d_data_mex_4_threads(obj)
            cleanup_handle = set_temporary_config_options( ...
                hor_config(), ...
                'use_mex', true, ...
                'threads', 4 ...
                );  %#ok  unused variable ok as it's a cleanup object
            
            [s, e] = obj.pix_with_pages_2d.compute_bin_data(obj.ref_npix_data_2d);
            
            % Scale the signal and error to account for rounding errors
            max_s = max(s(:));
            scaled_s = s/max_s;
            scaled_ref_s = obj.ref_s_data_2d/max_s;
            
            max_e = max(e(:));
            scaled_e = e/max_e;
            scaled_ref_e = obj.ref_e_data_2d/max_e;
            
            assertEqual(scaled_s, scaled_ref_s, '', obj.FLOAT_TOLERANCE);
            assertEqual(scaled_e, scaled_ref_e, '', obj.FLOAT_TOLERANCE);
        end
        
        function test_file_backed_2d_data_no_mex_matches_ref_file(obj)
            cleanup_handle = set_temporary_config_options( ...
                hor_config(), ...
                'use_mex', false, ...
                'threads', 4 ...
                );  %#ok  unused variable ok as it's a cleanup object
            
            [s, e] = obj.pix_with_pages_2d.compute_bin_data(obj.ref_npix_data_2d);
            
            % Scale the signal and error to account for rounding errors
            max_s = max(s(:));
            scaled_s = s/max_s;
            scaled_ref_s = obj.ref_s_data_2d/max_s;
            
            max_e = max(e(:));
            scaled_e = e/max_e;
            scaled_ref_e = obj.ref_e_data_2d/max_e;
            
            assertEqual(scaled_s, scaled_ref_s, '', obj.FLOAT_TOLERANCE);
            assertEqual(scaled_e, scaled_ref_e, '', obj.FLOAT_TOLERANCE);
        end
        
        function test_correct_output_file_backed_mex_off(obj)
            cleanup_handle = set_temporary_config_options( ...
                hor_config(), 'use_mex', false ...
                );  %#ok  unused variable ok as it's a cleanup object
            
            [s, e] = obj.pix_with_pages.compute_bin_data(obj.ref_npix_data);
            
            assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
            assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
        end
        
        function test_mex_rets_empty_arrays_if_num_pix_is_zero(~)
            cleanup_handle = set_temporary_config_options( ...
                hor_config(), 'use_mex', true ...
                );  %#ok  unused variable ok as it's a cleanup object
            
            p = PixelData();
            [s, e] = p.compute_bin_data([]);
            
            assertTrue(isempty(s));
            assertTrue(isempty(e));
        end
        
        function test_nomex_empty_arrays_if_npix_is_zero(~)
            cleanup_handle = set_temporary_config_options( ...
                hor_config(), 'use_mex', false ...
                );  %#ok  unused variable ok as it's a cleanup object
            
            p = PixelData();
            [s, e] = p.compute_bin_data([]);
            
            assertTrue(isempty(s));
            assertTrue(isempty(e));
        end
        
        function test_sig_and_var_set_to_zero_where_npix_is_zero_mex_off(~)
            cleanup_handle = set_temporary_config_options( ...
                hor_config(), 'use_mex', false ...
                );  %#ok  unused variable ok as it's a cleanup object
            
            npix = [1, 2, 3, 0, 5, 6, 0, 0, 9, 10, 0];
            pix = PixelData(ones(PixelData.DEFAULT_NUM_PIX_FIELDS, sum(npix)));
            
            [s, e] = pix.compute_bin_data(npix);
            
            where_0 = npix == 0;
            assertEqual(s(where_0), zeros(1, sum(where_0)));
            assertEqual(e(where_0), zeros(1, sum(where_0)));
            assertEqual(s(~where_0), ones(1, sum(~where_0)));
            assertEqual(e(~where_0), ones(1, sum(~where_0))./npix(npix ~= 0));
        end
        
        function test_sig_and_var_set_to_zero_where_npix_is_zero_mex_on(~)
            cleanup_handle = set_temporary_config_options( ...
                hor_config(), 'use_mex', true ...
                );  %#ok  unused variable ok as it's a cleanup object
            
            npix = [1, 2, 3, 0, 5, 6, 0, 0, 9, 10, 0];
            pix = PixelData(ones(PixelData.DEFAULT_NUM_PIX_FIELDS, sum(npix)));
            
            [s, e] = pix.compute_bin_data(npix);
            
            where_0 = npix == 0;
            assertEqual(s(where_0), zeros(1, sum(where_0)));
            assertEqual(e(where_0), zeros(1, sum(where_0)));
            assertEqual(s(~where_0), ones(1, sum(~where_0)));
            assertEqual(e(~where_0), ones(1, sum(~where_0))./npix(npix ~= 0));
        end
    end
    
end
