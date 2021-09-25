classdef test_PixelData < TestCase & common_state_holder
    
    properties
        
        SMALL_PG_SIZE = 1e6;  % 1Mb
        ALL_IN_MEM_PG_SIZE = 1e12;
        
        raw_pix_data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, 10);
        raw_pix_range;
        tst_source_sqw_file_path = '../test_sqw_file/sqw_1d_1.sqw';
        tst_sqw_file_full_path = '';
        this_dir = fileparts(mfilename('fullpath'));
        
        pixel_data_obj;
        pix_data_from_file;
        pix_data_from_faccess;
        pix_data_small_page;
        pix_fields = {'u1', 'u2', 'u3', 'dE', 'coordinates', 'q_coordinates', ...
            'run_idx', 'detector_idx', 'energy_idx', 'signal', ...
            'variance'};
    end
    
    properties (Constant)
        NUM_BYTES_IN_VALUE = PixelData.DATA_POINT_SIZE;
        NUM_COLS_IN_PIX_BLOCK = PixelData.DEFAULT_NUM_PIX_FIELDS;
        BYTES_IN_PIXEL = test_PixelData.NUM_BYTES_IN_VALUE*test_PixelData.NUM_COLS_IN_PIX_BLOCK;
        RUN_IDX = 5;
        SIGNAL_IDX = 8;
        VARIANCE_IDX = 9;
    end
    
    methods (Access = private)
        
        function [pix_data,pix_range] = get_random_pix_data_(~, rows)
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, rows);
            pix_range = [min(data(1:4,:),[],2),max(data(1:4,:),[],2)]';
            pix_data = PixelData(data);
            
        end
        function ref_range = get_ref_range(~,data)
            ref_range = [min(data(1:4, :),[],2),...
                max(data(1:4, :),[],2)]';
        end
        
    end
    
    methods
        
        function obj = test_PixelData(~)
            obj = obj@TestCase('test_PixelData');            
            
            obj.raw_pix_range = obj.get_ref_range(obj.raw_pix_data);
            
            source_sqw_file = java.io.File(pwd(), obj.tst_source_sqw_file_path);
            source_sqw_file  = char(source_sqw_file .getCanonicalPath());
            [~,fn] = fileparts(source_sqw_file);
            test_sqw_file_full_path = fullfile(tmp_dir,[fn,'.sqw']);
            copyfile(source_sqw_file,test_sqw_file_full_path);
            modify_pix_ranges(test_sqw_file_full_path);
            obj.tst_sqw_file_full_path = test_sqw_file_full_path;
            
            % Construct an object from raw data
            obj.pixel_data_obj = PixelData(obj.raw_pix_data);
            % Construct an object from a file
            obj.pix_data_from_file = PixelData(obj.tst_sqw_file_full_path);
            % Construct an object from a file accessor
            f_accessor = sqw_formats_factory.instance().get_loader(obj.tst_sqw_file_full_path);
            obj.pix_data_from_faccess = PixelData(f_accessor);
            % Construct an object from file accessor with small page size
            obj.pix_data_small_page = PixelData(f_accessor, obj.SMALL_PG_SIZE);
        end
                
        % --- Tests for in-memory operations ---
        function test_default_construction_sets_empty_pixel_data(~)
            pix_data = PixelData();
            num_cols = 9;
            assertEqual(pix_data.data, zeros(num_cols, 0));
            assertEqual(pix_data.pix_range,[inf,inf,inf,inf;-inf,-inf,-inf,-inf])
        end
        
        function test_PIXELDATA_raised_on_construction_with_data_with_lt_9_cols(~)
            f = @() PixelData(ones(3, 3));
            assertExceptionThrown(f, 'HORACE:PixelData:invalid_argument');
        end
        
        function test_PIXELDATA_raised_on_construction_with_data_with_gt_9_cols(~)
            f = @() PixelData(ones(10, 3));
            assertExceptionThrown(f, 'HORACE:PixelData:invalid_argument');
        end
        
        function test_coordinates_returns_empty_array_if_pixel_data_empty(~)
            pix_data = PixelData();
            assertTrue(isempty(pix_data.coordinates));
            assertEqual(pix_data.pix_range,[inf,inf,inf,inf;-inf,-inf,-inf,-inf])
        end
        
        function test_pixel_data_is_set_to_input_data_on_construction(obj)
            assertEqual(obj.pixel_data_obj.data, obj.raw_pix_data);
            assertEqual(obj.pixel_data_obj.pix_range, obj.raw_pix_range);
            
        end
        
        function test_u1_returns_first_dim_in_coordinates_array(obj)
            u1 = obj.pixel_data_obj.u1;
            assertEqual(u1, obj.pixel_data_obj.coordinates(1, :));
            range = obj.pixel_data_obj.pix_range;
            assertEqual(range(:,1),[min(u1,[],2);max(u1,[],2)]);
        end
        
        function test_u1_sets_the_first_dim_in_coordinates_array(obj)
            [pix_data_obj,range] = obj.get_random_pix_data_(10);
            pix_data_obj.u1 = 1;
            assertEqual(pix_data_obj.coordinates(1, :), ones(1, 10));
            range(:,1) = 1;
            assertEqual(pix_data_obj.pix_range, range);
            assertEqual(pix_data_obj.page_range,range)
        end
        
        function test_u2_returns_second_dim_in_coordinates_array(obj)
            u2 = obj.pixel_data_obj.u2;
            assertEqual(u2, obj.pixel_data_obj.coordinates(2, :));
        end
        
        function test_u2_sets_the_second_dim_in_coordinates_array(obj)
            [pix_data_obj,ref_range] = obj.get_random_pix_data_(10);
            pix_data_obj.u2 = 1;
            assertEqual(pix_data_obj.coordinates(2, :), ones(1, 10));
            
            ref_range(:,2) = [1;1];
            range = pix_data_obj.pix_range;
            assertEqual(ref_range,range);
            assertEqual(pix_data_obj.page_range,range)
        end
        
        function test_u3_returns_third_dim_in_coordinates_array(obj)
            u3 = obj.pixel_data_obj.u3;
            assertEqual(u3, obj.pixel_data_obj.coordinates(3, :));
        end
        
        function test_u3_sets_the_third_dim_in_coordinates_array(obj)
            [pix_data_obj,ref_range] = obj.get_random_pix_data_(10);
            pix_data_obj.u3 = 1;
            assertEqual(pix_data_obj.coordinates(3, :), ones(1, 10));
            
            ref_range(:,3) = [1;1];
            range = pix_data_obj.pix_range;
            assertEqual(ref_range,range);
            assertEqual(pix_data_obj.page_range,range)
        end
        
        function test_dE_returns_fourth_dim_in_coordinates_array(obj)
            dE = obj.pixel_data_obj.dE;
            assertEqual(dE, obj.pixel_data_obj.coordinates(4, :));
        end
        
        function test_dE_sets_the_fourth_dim_in_coordinates_array(obj)
            [pix_data_obj,ref_range] = obj.get_random_pix_data_(10);
            pix_data_obj.dE = 1;
            assertEqual(pix_data_obj.coordinates(4, :), ones(1, 10));
            
            ref_range(:,4) = [1;1];
            range = pix_data_obj.pix_range;
            assertEqual(ref_range,range);
            assertEqual(pix_data_obj.page_range,range)
            
        end
        
        function test_q_coordinates_returns_first_3_dims_of_coordinates(obj)
            q_coords = obj.pixel_data_obj.q_coordinates;
            assertEqual(q_coords, obj.pixel_data_obj.q_coordinates);
        end
        
        function test_setting_q_coordinates_updates_u1_u2_and_u3(obj)
            pix_data_obj = obj.get_random_pix_data_(10);
            pix_data_obj.q_coordinates = ones(3, 10);
            assertEqual(pix_data_obj.u1, ones(1, 10));
            assertEqual(pix_data_obj.u2, ones(1, 10));
            assertEqual(pix_data_obj.u3, ones(1, 10));
        end
        
        function test_get_coordinates_returns_coordinate_data(obj)
            coord_data = obj.raw_pix_data(1:4, :);
            assertEqual(obj.pixel_data_obj.coordinates, coord_data);
        end
        
        function test_run_idx_returns_run_index_data(obj)
            run_indices = obj.raw_pix_data(5, :);
            assertEqual(obj.pixel_data_obj.run_idx, run_indices)
        end
        
        function test_detector_idx_returns_detector_index_data(obj)
            detector_indices = obj.raw_pix_data(6, :);
            assertEqual(obj.pixel_data_obj.detector_idx, detector_indices)
        end
        
        function test_energy_idx_returns_energy_bin_number_data(obj)
            energy_bin_nums = obj.raw_pix_data(7, :);
            assertEqual(obj.pixel_data_obj.energy_idx, energy_bin_nums)
        end
        
        function test_signal_returns_signal_array(obj)
            signal_array = obj.raw_pix_data(8, :);
            assertEqual(obj.pixel_data_obj.signal, signal_array)
        end
        
        function test_variance_returns_variance_array(obj)
            variance_array = obj.raw_pix_data(9, :);
            assertEqual(obj.pixel_data_obj.variance, variance_array)
        end
        
        function test_PIXELDATA_error_raised_if_setting_data_with_lt_9_cols(~)
            f = @(x) PixelData(zeros(x, 10));
            for i = [-10, -5, 0, 5]
                assertExceptionThrown(@() f(i), 'HORACE:PixelData:invalid_argument');
            end
        end
        
        function test_num_pixels_returns_the_number_of_rows_in_the_data_block(obj)
            assertEqual(obj.pixel_data_obj.num_pixels, 10);
        end
        
        function test_coordinate_data_is_settable(obj)
            num_rows = 10;
            pix_data_obj = obj.get_random_pix_data_(num_rows);
            
            new_coord_data = ones(4, num_rows);
            pix_data_obj.coordinates = new_coord_data;
            assertEqual(pix_data_obj.coordinates, new_coord_data);
            assertEqual(pix_data_obj.data(1:4, :), new_coord_data);
        end
        
        function test_error_raised_if_setting_coordinates_with_wrong_num_rows(obj)
            num_rows = 10;
            pix_data_obj = obj.get_random_pix_data_(num_rows);
            new_coord_data = ones(4, num_rows - 1);
            
            function set_coordinates(data)
                pix_data_obj.coordinates = data;
            end
            
            f = @() (set_coordinates(new_coord_data));
            assertExceptionThrown(f, 'MATLAB:subsassigndimmismatch');
        end
        
        function test_error_raised_if_setting_coordinates_with_wrong_num_cols(obj)
            num_rows = 10;
            pix_data_obj = obj.get_random_pix_data_(num_rows);
            
            function set_coordinates(data)
                pix_data_obj.coordinates = data;
            end
            
            new_coord_data = ones(3, num_rows);
            f = @() set_coordinates(new_coord_data);
            assertExceptionThrown(f, 'MATLAB:subsassigndimmismatch');
        end
        
        function test_PixelData_object_with_underlying_data_is_not_empty(obj)
            assertFalse(isempty(obj.pixel_data_obj));
        end
        
        function test_default_PixelData_object_is_empty(~)
            pix_data_obj = PixelData();
            assertTrue(isempty(pix_data_obj));
        end
        
        function test_PIXELDATA_error_if_constructed_with_struct(~)
            s = struct();
            f = @() PixelData(s);
            assertExceptionThrown(f, 'HORACE:PixelData:invalid_argument');
        end
        
        function test_PIXELDATA_error_if_constructed_with_cell_array(~)
            s = {'a', 1};
            f = @() PixelData(s);
            assertExceptionThrown(f, 'HORACE:PixelData:invalid_argument');
        end
        function test_PixelData_set_data_all(~)
            pix_data_obj = PixelData();
            data = zeros(9,1);
            pix_data_obj.set_data('all',data)
            assertEqual(pix_data_obj.num_pixels,1);
            assertEqual(pix_data_obj.coordinates,zeros(4,1));
            
        end
        function test_PixelData_set_data_all_wrong_size(~)
            pix_data_obj = PixelData();
            data = zeros(4,1);
            f = @()set_data(pix_data_obj,'all',data);
            
            assertExceptionThrown(f, 'HORACE:PixelData:invalid_argument');            
            
        end
        
        function test_PIXELDATA_error_if_data_set_with_non_numeric_type(~)
            pix_data_obj = PixelData();
            
            function set_data(data)
                pix_data_obj.data = data;
            end
            
            f = @() set_data({1, 'abc'});
            assertExceptionThrown(f, 'HORACE:PixelData:invalid_argument');
        end
        
        function test_num_pix_returns_the_number_of_elements_in_the_data(obj)
            assertEqual(obj.pixel_data_obj.num_pixels*PixelData.DEFAULT_NUM_PIX_FIELDS,...
                numel(obj.pixel_data_obj.data));
        end
        
        function test_can_construct_from_another_PixelData_object(obj)
            pixel_data_obj_copy = PixelData(obj.pixel_data_obj);
            assertEqual(pixel_data_obj_copy.data, obj.pixel_data_obj.data);
        end
        
        function test_get_data_returns_coordinates_for_given_index_range(obj)
            pix_data_obj = obj.get_random_pix_data_(10);
            coords = pix_data_obj.get_data({'coordinates'}, 2:6);
            assertEqual(coords, pix_data_obj.coordinates(:, 2:6));
        end
        
        function test_get_data_returns_multiple_fields_for_given_index_range(obj)
            pix_data_obj = obj.get_random_pix_data_(10);
            coord_sig = pix_data_obj.get_data({'coordinates', 'signal'}, 4:9);
            expected_coord_sig = [pix_data_obj.coordinates(:, 4:9); ...
                pix_data_obj.signal(4:9)];
            assertEqual(coord_sig, expected_coord_sig);
        end
        
        function test_get_data_returns_full_pixel_range_if_no_range_given(obj)
            pix_data_obj = obj.get_random_pix_data_(10);
            coord_sig = pix_data_obj.get_data({'coordinates', 'signal'});
            expected_coord_sig = [pix_data_obj.coordinates; pix_data_obj.signal];
            assertEqual(coord_sig, expected_coord_sig);
        end
        
        function test_get_data_allows_data_retrieval_for_single_field(obj)
            for i = 1:numel(obj.pix_fields)
                field_data = obj.pixel_data_obj.get_data(obj.pix_fields{i});
                assertEqual(field_data, obj.pixel_data_obj.(obj.pix_fields{i}));
            end
        end
        
        function test_get_data_throws_PIXELDATA_on_non_valid_field_name(obj)
            f = @() obj.pixel_data_obj.get_data('not_a_field');
            assertExceptionThrown(f, 'HORACE:PixelData:invalid_argument');
        end
        
        function test_get_data_orders_columns_corresponding_to_input_cell_array(obj)
            pix_data_obj = obj.get_random_pix_data_(10);
            data_subset = pix_data_obj.get_data({'detector_idx', 'signal', 'run_idx'});
            assertEqual(data_subset(1, :), pix_data_obj.detector_idx);
            assertEqual(data_subset(2, :), pix_data_obj.signal);
            assertEqual(data_subset(3, :), pix_data_obj.run_idx);
        end
        
        function test_cat_combines_given_PixelData_objects(obj)
            pix_data_obj1 = obj.get_random_pix_data_(10);
            pix_data_obj2 = obj.get_random_pix_data_(5);
            
            combined_pix = PixelData.cat(pix_data_obj1, pix_data_obj2);
            
            assertEqual(combined_pix.num_pixels, 15);
            assertEqual(combined_pix.data, ...
                horzcat(pix_data_obj1.data, pix_data_obj2.data));
        end
        
        function test_get_pixels_returns_PixelData_obj_with_given_pix_indices(~)
            data = rand(9, 10);
            pix = PixelData(data);
            sub_pix = pix.get_pixels([3, 5, 7]);
            assertTrue(isa(pix, 'PixelData'));
            assertEqual(sub_pix.data, data(:, [3, 5, 7]));
        end
        
        function test_get_pixels_returns_PixelData_with_equal_num_cols(obj)
            pix = obj.get_random_pix_data_(10);
            orignal_size = size(pix.data, 1);
            sub_pix = pix.get_pixels(1:5);
            assertEqual(size(sub_pix.data, 1), orignal_size);
        end
        
        function test_load_obj_returns_equivalent_object(~)
            pix = PixelData.loadobj(PixelData(ones(9, 10)));
            assertEqual(pix.data, ones(9, 10));
        end
        
        function test_construction_with_int_fills_underlying_data_with_zeros(~)
            npix = 20;
            pix = PixelData(npix);
            assertEqual(pix.num_pixels, npix);
            assertEqual(pix.data, zeros(9, npix));
            assertEqual(pix.variance, zeros(1, npix));
        end
        
        function test_construction_with_float_raises_PIXELDATA_error(~)
            f = @() PixelData(1.2);
            assertExceptionThrown(f, 'HORACE:PixelData:invalid_argument');
        end
        
        function test_construction_with_file_path_sets_file_path_on_object(obj)
            assertEqual(obj.pix_data_from_file.file_path, obj.tst_sqw_file_full_path);
        end
        
        function test_construction_with_file_path_populates_data_from_file(obj)
            assertFalse(isempty(obj.pix_data_from_file));
            expected_signal_chunk = [0, 0, 0, 0, 0483.5, 4463.0, 1543.0, 0, 0, 0];
            assertEqual(obj.pix_data_from_file.signal(9825:9834), ...
                expected_signal_chunk);
        end
        
        function test_construction_with_file_path_sets_num_pixels_in_file(obj)
            f_accessor = sqw_formats_factory.instance().get_loader(...
                obj.tst_sqw_file_full_path);
            assertEqual(obj.pix_data_from_file.num_pixels, f_accessor.npixels);
        end
        
        function test_error_on_construction_with_non_existent_file(~)
            file_path = 'not-a-file';
            f = @() PixelData(file_path);
            assertExceptionThrown(f, 'SQW_FILE_IO:runtime_error');
        end
        
        function test_construction_with_faccess_populates_data_from_file(obj)
            assertFalse(isempty(obj.pix_data_from_faccess));
            expected_signal_chunk = [0, 0, 0, 0, 0483.5, 4463.0, 1543.0, 0, 0, 0];
            assertEqual(obj.pix_data_from_faccess.signal(9825:9834), ...
                expected_signal_chunk);
        end
        
        function test_construction_with_faccess_sets_file_path(obj)
            assertEqual(obj.pix_data_from_faccess.file_path, obj.tst_sqw_file_full_path);
        end
        
        function test_page_size_is_set_after_getter_call_when_given_as_argument(obj)
            mem_alloc = obj.SMALL_PG_SIZE;  % 1Mb
            expected_page_size = floor(...
                mem_alloc/(obj.NUM_BYTES_IN_VALUE*obj.NUM_COLS_IN_PIX_BLOCK));
            % the first page is loaded on access, so this first assert which accesses
            % .variance is necessary to set pix.page_size
            assertEqual(size(obj.pix_data_small_page.variance), ...
                [1, obj.pix_data_small_page.page_size]);
            assertEqual(obj.pix_data_small_page.page_size, expected_page_size);
        end
        
        function test_calling_getter_returns_data_for_single_page(obj)
            data = rand(9, 30);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            assertEqual(size(pix.signal), [1, pix.page_size]);
            assertEqual(pix.signal, data(8, 1:11));
        end
        
        function test_calling_get_data_returns_data_for_single_page(obj)
            data = rand(9, 30);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            sig_var = pix.get_data({'signal', 'variance'}, 3:8);
            assertEqual(sig_var, data(8:9, 3:8));
        end
        
        function test_data_values_are_not_effected_by_changes_in_copies(~)
            n_rows = 5;
            p1 = PixelData(ones(9, n_rows));
            p2 = copy(p1);
            p2.u1 = zeros(1, n_rows);
            assertEqual(p2.u1, zeros(1, n_rows));
            assertEqual(p1.u1, ones(1, n_rows));
        end
        
        function test_number_of_pixels_in_page_matches_memory_usage_size(obj)
            data = rand(9, 30);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            pix.u1;
            assertEqual(size(pix.data, 2), npix_in_page);
        end
        
        function test_has_more_rets_true_if_there_are_subsequent_pixels_in_file(obj)
            data = rand(9, 12);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            assertTrue(pix.has_more());
        end
        
        function test_has_more_rets_false_if_all_data_in_page(obj)
            data = rand(9, 11);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            assertFalse(pix.has_more());
        end
        
        function test_has_more_rets_false_if_all_data_created_in_memory(~)
            data = rand(9, 30);
            pix = PixelData(data);
            assertFalse(pix.has_more());
        end
        
        function test_advance_loads_next_page_of_data_into_memory_for_props(obj)
            data = rand(9, 30);
            f = @(pix, iter) assertEqual(pix.signal, ...
                data(8, (iter*11 + 1):((iter*11 + 1) + pix.page_size - 1)));
            obj.do_pixel_data_loop_with_f(f, data);
        end
        
        function test_advance_raises_PIXELDATA_if_at_end_of_data(obj)
            npix = 30;
            data = rand(9, npix);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            f = @() obj.advance_pix(pix, floor(npix/npix_in_page + 1));
            assertExceptionThrown(f, 'PIXELDATA:move_to_page');
        end
        
        function test_advance_does_nothing_if_PixelData_not_file_backed(~)
            data = rand(9, 10);
            pix = PixelData(data);
            pix.advance();
            assertEqual(pix.data, data);
        end
        
        function test_advance_while_loop_to_sum_signal_data(obj)
            data = randi([0, 99], 9, 30);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            signal_sum = sum(pix.signal);
            while pix.has_more()
                pix.advance();
                signal_sum = signal_sum + sum(pix.signal);
            end
            
            assertEqual(signal_sum, sum(data(8, :)));
        end
        
        function test_page_size_returns_size_of_data_held_in_memory(obj)
            pix = obj.get_random_pix_data_(10);
            assertEqual(pix.page_size, 10);
        end
        
        function test_empty_PixelData_object_has_page_size_zero(~)
            pix = PixelData();
            assertEqual(pix.page_size, 0);
        end
        
        function test_constructing_from_PixelData_with_valid_file_inits_faccess(obj)
            new_pix = PixelData(obj.pix_data_small_page);
            assertEqual(new_pix.file_path, obj.tst_sqw_file_full_path);
            assertEqual(new_pix.num_pixels, obj.pix_data_small_page.num_pixels);
            assertEqual(new_pix.signal, obj.pix_data_small_page.signal);
            assertTrue(new_pix.has_more());
        end
        
        function test_move_to_first_page_resets_to_first_page_in_file(obj)
            data = rand(9, 30);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            pix.advance();
            assertEqual(pix.u1, data(1, 12:22));  % currently on the second page
            pix.move_to_first_page();
            assertEqual(pix.u1, data(1, 1:11));  % should be back to the first page
        end
        
        function test_move_to_first_page_keeps_data_if_pix_not_file_backed(obj)
            pix = obj.get_random_pix_data_(30);
            u1 = pix.u1;
            pix.move_to_first_page();
            assertEqual(pix.u1, u1);
        end
        
        function test_instance_has_page_size_after_construction(~)
            data = rand(9, 10);
            faccess = FakeFAccess(data);
            pix = PixelData(faccess);
            assertEqual(pix.page_size, 10);
        end
        
        function test_editing_a_field_loads_page(obj)
            data = rand(9, 10);
            faccess = FakeFAccess(data);
            for i = 1:numel(obj.pix_fields)
                pix = PixelData(faccess);
                pix.(obj.pix_fields{i}) = 1;
                assertEqual(pix.page_size, 10);
            end
        end
        
        function test_setting_file_backed_pixels_preserves_changes_after_advance(obj)
            data = rand(9, 30);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            pix.u1 = 1;  % sets page 1 of u1 to all ones
            pix.advance();  % move to second page
            assertEqual(pix.u1, data(1, (npix_in_page + 1):(2*npix_in_page)));
            pix.move_to_first_page();
            assertEqual(pix.u1, ones(1, npix_in_page));
        end
        
        function test_dirty_pix_tmp_files_are_deleted_when_pix_out_of_scope(obj)
            old_rng_state = rng();
            clean_up = onCleanup(@() rng(old_rng_state));
            fixed_seed = 774015;
            rng(fixed_seed, 'twister');  % this seed gives an expected object_id_ = 54452
            expected_tmp_dir = fullfile( ...
                get(parallel_config, 'working_directory'), ...
                'sqw_pix54452' ...
                );

            function do_pix_creation_and_delete()
                data = rand(9, 30);
                npix_in_page = 11;
                pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
                
                pix.u1 = 1;
                pix.advance();  % creates tmp file for first page
                assertTrue( ...
                    logical(exist(expected_tmp_dir, 'dir')), ...
                    sprintf('Temp directory ''%s'' not created', expected_tmp_dir) ...
                    );
            end
            
            do_pix_creation_and_delete();
            assertFalse(logical(exist(expected_tmp_dir, 'dir')), ...
                'Temp directory not deleted');
        end
        
        function test_all_page_changes_saved_after_edit_advance_and_reset(obj)
            data = zeros(9, 30);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            % set all u1 values in each page to 1
            pix.u1 = 1;
            while pix.has_more()
                pix.advance();  % move to second page
                pix.u1 = 1;  % sets page 1 of u1 to all ones
            end
            pix.move_to_first_page();
            
            % check all u1 values are still 1
            assertEqual(pix.u1, ones(1, pix.page_size));
            while pix.has_more()
                pix.advance();
                assertEqual(pix.u1, ones(1, pix.page_size));
            end
        end
        
        function test_correct_values_returned_with_mix_of_clean_and_dirty_pages(obj)
            data = zeros(9, 30);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            % set coordinates of page 1 and 3 to all ones
            pix.u1 = 1;
            pix.advance();  % move to second page
            pix.advance();  % move to third page
            pix.u1 = 1;
            
            pix.move_to_first_page();
            
            assertEqual(pix.u1, ones(1, pix.page_size));
            pix.advance();
            assertEqual(pix.u1, zeros(1, pix.page_size));
            pix.advance();
            assertEqual(pix.u1, ones(1, pix.page_size));
        end
        
        function test_you_cannot_set_page_of_data_with_smaller_sized_array(obj)
            data = zeros(9, 30);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            function set_pix(data)
                pix.data = data;
            end
            
            f = @() set_pix(ones(9, 10));
            assertExceptionThrown(f, 'HORACE:PixelData:invalid_argument');
        end
        
        function test_you_cannot_set_page_of_data_with_larger_sized_array(obj)
            data = zeros(9, 30);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            function set_pix(data)
                pix.data = data;
            end
            
            f = @() set_pix(ones(9, 20));
            assertExceptionThrown(f, 'HORACE:PixelData:invalid_argument');
        end
        
        function test_num_pixels_is_a_double_if_faccess_returns_uint(~)
            npix = 30;
            data = rand(9, npix);
            faccess = FakeFAccess(data);
            faccess = faccess.set_npixels(uint64(npix));
            
            pix = PixelData(faccess);
            assertEqual(class(pix.num_pixels), 'double');
        end
        
        function test_num_pixels_is_a_double_if_data_in_memory(obj)
            assertEqual(class(obj.pixel_data_obj.num_pixels), 'double');
        end
        
        function test_num_pixels_is_a_double_if_more_than_one_page_of_data(obj)
            assertEqual(class(obj.pix_data_small_page.num_pixels), 'double');
        end
        
        function test_copy_on_same_page_as_original_when_more_than_1_page(obj)
            pix_original = PixelData(obj.tst_sqw_file_full_path, 1e6);
            pix_original.signal = 1;
            pix_original.advance();
            
            pix_copy = copy(pix_original);
            
            assertEqual(pix_copy.data, pix_original.data);
            while pix_original.has_more()
                pix_original.advance();
                pix_copy.advance();
                assertEqual(pix_copy.data, pix_original.data);
            end
            
            pix_copy.move_to_first_page();
            pix_original.move_to_first_page();
            assertEqual(pix_copy.data, pix_original.data);
        end
        
        function test_copy_on_same_pg_as_original_when_more_than_1_pg_no_advance(obj)
            pix_original = PixelData(obj.tst_sqw_file_full_path, 1e6);
            pix_original.signal = 1;
            
            pix_copy = copy(pix_original);
            
            assertEqual(pix_copy.data, pix_original.data);
            while pix_original.has_more()
                pix_original.advance();
                pix_copy.advance();
                assertEqual(pix_copy.data, pix_original.data);
            end
        end
        
        function test_changes_to_original_persistent_in_copy_if_1_page_in_file(obj)
            pix_original = PixelData(obj.tst_sqw_file_full_path, 1e9);
            pix_original.signal = 1;
            pix_original.advance();
            
            pix_copy = copy(pix_original);
            
            assertEqual(pix_copy.data, pix_original.data);
            while pix_original.has_more()
                % we shouldn't enter here, but we should check the same API for
                % data with > 1 page works for single page
                pix_original.advance();
                pix_copy.advance();
                assertEqual(pix_copy.data, pix_original.data);
            end
            
            pix_copy.move_to_first_page();
            pix_original.move_to_first_page();
            assertEqual(pix_copy.data, pix_original.data);
        end
        
        function test_changes_to_orig_persistent_in_copy_if_1_pg_in_file_no_adv(obj)
            pix_original = PixelData(obj.tst_sqw_file_full_path, 1e9);
            pix_original.signal = 1;
            
            pix_copy = copy(pix_original);
            
            assertEqual(pix_copy.data, pix_original.data);
            while pix_original.has_more()
                % we shouldn't enter here, but we should check the same API for
                % data with > 1 page works for single page
                pix_original.advance();
                pix_copy.advance();
                assertEqual(pix_copy.data, pix_original.data);
            end
        end
        
        function test_changes_to_copy_have_no_affect_on_original_after_advance(obj)
            data = zeros(9, 30);
            npix_in_page = 11;
            pix_original = obj.get_pix_with_fake_faccess(data, npix_in_page);
            pix_original.signal = 1;
            pix_original.advance();
            
            pix_copy = copy(pix_original);
            pix_copy.move_to_first_page();
            pix_copy.signal = 2;
            pix_copy.advance();
            
            pix_original.move_to_first_page();
            assertEqual(pix_original.signal, ones(1, numel(pix_original.signal)));
            
            pix_copy.move_to_first_page();
            assertEqual(pix_copy.signal, 2*ones(1, numel(pix_copy.signal)));
        end
        
        function test_changes_to_copy_have_no_affect_on_original_no_advance(obj)
            data = zeros(9, 30);
            npix_in_page = 11;
            pix_original = obj.get_pix_with_fake_faccess(data, npix_in_page);
            pix_original.signal = 1;
            
            pix_copy = copy(pix_original);
            pix_copy.move_to_first_page();
            pix_copy.signal = 2;
            
            assertEqual(pix_original.signal, ones(1, numel(pix_original.signal)));
            assertEqual(pix_copy.signal, 2*ones(1, numel(pix_copy.signal)));
        end
        
        function test_changes_to_original_before_copy_are_reflected_in_copies(obj)
            data = zeros(9, 30);
            npix_in_page = 11;
            pix_original = obj.get_pix_with_fake_faccess(data, npix_in_page);
            pix_original.signal = 1;
            pix_original.advance();
            
            pix_copy = copy(pix_original);
            pix_copy.move_to_first_page();
            
            assertEqual(pix_copy.signal, ones(1, numel(pix_copy.signal)));
        end
        
        function test_changes_to_original_kept_in_copy_after_advance(obj)
            pix_original = PixelData(obj.tst_sqw_file_full_path, 1e2);
            pix_original.signal = 1;
            
            pix_copy = copy(pix_original);
            pix_copy.advance();
            
            pix_copy.move_to_first_page();
            assertEqual(pix_copy.signal, ones(1, numel(pix_copy.signal)));
        end
        
        function test_change_to_original_after_copy_does_not_affect_copy(obj)
            data = zeros(9, 30);
            npix_in_page = 11;
            pix_original = obj.get_pix_with_fake_faccess(data, npix_in_page);
            pix_copy = copy(pix_original);
            
            pix_copy.signal = 1;
            pix_copy.advance();
            
            pix_original.signal = 2;
            pix_original.advance();
            
            pix_copy.move_to_first_page();
            assertEqual(pix_copy.signal, ones(1, numel(pix_copy.signal)));
        end
        
        function test_page_written_correctly_when_page_size_gt_mem_chunk_size(obj)
            warning('off', 'HOR_CONFIG:set_mem_chunk_size');
            hc = hor_config;
            old_config = hc.get_data_to_store();
            npix_to_write = 28;
            size_of_float = 4;
            hc.mem_chunk_size = npix_to_write*size_of_float;
            
            function clean_up_func(conf_to_restore)
                set(hor_config, conf_to_restore);
                warning('on', 'HOR_CONFIG:set_mem_chunk_size');
            end
            
            clean_up = onCleanup(@() clean_up_func(old_config));
            
            npix_in_page = 90;
            data = zeros(obj.NUM_COLS_IN_PIX_BLOCK, npix_in_page + 10);
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            pix.data = ones(obj.NUM_COLS_IN_PIX_BLOCK, npix_in_page);
            pix.advance();
            pix.move_to_first_page();
            
            assertEqual(pix.data, ones(obj.NUM_COLS_IN_PIX_BLOCK, npix_in_page));
        end
        
        function test_pixels_read_correctly_if_final_pg_has_1_pixel(obj)
            data = rand(9, 10);
            npix_in_page = 3;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            assertEqual(pix.data, data(:, 1:3));
            pix.advance();
            assertEqual(pix.data, data(:, 4:6));
            pix.advance();
            assertEqual(pix.data, data(:, 7:9));
            pix.advance();
            assertEqual(pix.data, data(:, 10));
        end
        
        function test_unedited_dirty_pages_are_not_rewritten(obj)
            old_rng_state = rng();
            clean_up = onCleanup(@() rng(old_rng_state));
            fixed_seed = 774015;  % this seed gives an expected object_id_ = 06706
            rng(fixed_seed, 'twister');
            expected_tmp_dir = fullfile( ...
                get(parallel_config, 'working_directory'), ...
                'sqw_pix06706' ...
                );

            data = rand(9, 10);
            npix_in_page = 3;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            % edit a page such that it must be written to a file
            pix.signal = 1;
            [n_page,num_pages]=pix.advance();
            assertEqual(n_page,1)
            assertEqual(num_pages,1)
            tmp_file_path = fullfile(expected_tmp_dir, '000000001.tmp');
            assertTrue(logical(exist(tmp_file_path, 'file')));
            
            % record the temp file's original timestamp
            original_timestamp = java.io.File(tmp_file_path).lastModified();
            
            % move to first page and advance again
            pix.move_to_first_page();
            pix.signal;  % make sure there's data in memory
            pix.advance();  % no writing should happen here
            
            pause(0.2)  % let the file system catch up
            % get most recent timestamp
            new_timestamp = java.io.File(tmp_file_path).lastModified();
            
            assertEqual(new_timestamp, original_timestamp, ...
                'Temporary file timestamps are not equal.');
        end
        
        function test_cannot_append_more_pixels_than_can_fit_in_page(obj)
            npix_in_page = 5;
            mem_alloc = npix_in_page*obj.NUM_COLS_IN_PIX_BLOCK*obj.NUM_BYTES_IN_VALUE;
            pix = PixelData(zeros(9, 0), mem_alloc);
            
            data = ones(obj.NUM_COLS_IN_PIX_BLOCK, 11);
            pix_to_append = PixelData(data);
            
            f = @() pix.append(pix_to_append);
            assertExceptionThrown(f, 'PIXELDATA:append');
        end
        
        function test_you_can_append_to_empty_PixelData_object(obj)
            npix_in_page = 11;
            mem_alloc = npix_in_page*obj.NUM_COLS_IN_PIX_BLOCK*obj.NUM_BYTES_IN_VALUE;
            pix = PixelData(zeros(9, 0), mem_alloc);
            
            data = ones(obj.NUM_COLS_IN_PIX_BLOCK, npix_in_page);
            pix_to_append = PixelData(data);
            
            pix.append(pix_to_append);
            assertEqual(pix.data, data);
            assertEqual(pix.pix_range,ones(2,4));
        end
        
        function test_you_can_append_to_partially_full_PixelData_page(obj)
            npix_in_page = 11;
            nexisting_pix = 5;
            mem_alloc = npix_in_page*obj.NUM_COLS_IN_PIX_BLOCK*obj.NUM_BYTES_IN_VALUE;
            existing_data = rand(9, nexisting_pix);
            pix = PixelData(existing_data, mem_alloc);
            minmax = obj.get_ref_range(existing_data);
            assertEqual(pix.pix_range,minmax);
            
            data = ones(obj.NUM_COLS_IN_PIX_BLOCK, npix_in_page);
            pix_to_append = PixelData(data);
            assertEqual(pix_to_append.pix_range,ones(2,4));
            minmax(2,:) = ones(1,4);
            
            pg_offset = npix_in_page - nexisting_pix;
            expected_pg_1_data = horzcat(existing_data, data(:, 1:pg_offset));
            expected_pg_2_data = data(:, (pg_offset + 1):end);
            
            pix.append(pix_to_append);
            assertEqual(pix.pix_range,minmax)
            
            pix.move_to_first_page();
            assertEqual(pix.data, expected_pg_1_data, '', 1e-7);
            
            pix.advance();
            assertEqual(pix.data, expected_pg_2_data, '', 1e-7);
            assertEqual(pix.pix_range,minmax);
        end
        
        function test_you_can_append_to_PixelData_with_full_page(obj)
            npix_in_page = 11;
            nexisting_pix = 11;
            mem_alloc = npix_in_page*obj.NUM_COLS_IN_PIX_BLOCK*obj.NUM_BYTES_IN_VALUE;
            existing_data = rand(9, nexisting_pix);
            pix = PixelData(existing_data, mem_alloc);
            minmax = pix.pix_range;
            
            appended_data = ones(obj.NUM_COLS_IN_PIX_BLOCK, npix_in_page);
            pix_to_append = PixelData(appended_data);
            minmax(2,:) = ones(1,4);
            pix.append(pix_to_append);
            
            pix.move_to_first_page();
            assertEqual(pix.data, existing_data, '', 1e-7);
            assertEqual(pix.pix_range,minmax);
            
            pix.advance();
            assertEqual(pix.data, appended_data, '', 1e-7);
            assertEqual(pix.pix_range,minmax);
        end
        
        function test_appending_pixels_after_page_edited_preserves_changes(obj)
            npix_in_page = 11;
            num_pix = 24;
            mem_alloc = npix_in_page*obj.NUM_COLS_IN_PIX_BLOCK*obj.NUM_BYTES_IN_VALUE;
            original_data = rand(9, num_pix);
            
            pix = PixelData(original_data(:, 1:npix_in_page), mem_alloc);
            minmax = obj.get_ref_range(original_data);
            assertEqual(pix.data, original_data(:, 1:npix_in_page));
            pix.signal = ones(1, npix_in_page);
            
            for i = 2:ceil(num_pix/npix_in_page)
                start_idx = (i - 1)*npix_in_page + 1;
                end_idx = min(start_idx + npix_in_page - 1, num_pix);
                pix.append(PixelData(original_data(:, start_idx:end_idx)));
                assertEqual(pix.data, original_data(:, start_idx:end_idx));
            end
            assertEqual(pix.pix_range, minmax)
            
            pix.move_to_first_page();
            expected_pg_1_data = original_data(:, 1:npix_in_page);
            expected_pg_1_data(8, :) = 1;
            assertEqual(pix.data, expected_pg_1_data, '', 1e-7);
            assertEqual(pix.pix_range,minmax);
        end
        
        function test_you_can_append_to_file_backed_PixelData(obj)
            npix_in_page = 11;
            data = rand(9, 25);
            [pix,pix_range] = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            data_to_append = rand(9, 8);
            new_range = obj.get_ref_range(data_to_append);
            
            pix_to_append = PixelData(data_to_append);
            tot_range = [min(new_range(1,:),pix_range(1,:));...
                max(new_range(2,:),pix_range(2,:))];
            pix.append(pix_to_append);
            assertEqual(tot_range,pix.pix_range);
            
            expected_final_pg = horzcat(data(:, 23:end), data_to_append);
            assertEqual(pix.data, expected_final_pg);
            
            pix.move_to_first_page();
            assertEqual(pix.data, data(:, 1:npix_in_page), '', 1e-7);
            assertEqual(tot_range,pix.pix_range);
            
            pix.advance();
            assertEqual(pix.data, data(:, (npix_in_page + 1):(2*npix_in_page)), ...
                '', 1e-7);
            
            pix.advance();
            assertEqual(pix.data, expected_final_pg, '', 1e-7);
            assertEqual(tot_range,pix.pix_range);
        end
        
        function test_error_if_append_called_with_non_PixelData_object(~)
            pix = PixelData(rand(9, 1));
            f = @() pix.append(rand(9, 1));
            assertExceptionThrown(f, 'PIXELDATA:append');
        end
        
        function test_error_if_appending_pix_with_multiple_pages(obj)
            npix_in_page = 11;
            mem_alloc = npix_in_page*obj.NUM_COLS_IN_PIX_BLOCK*obj.NUM_BYTES_IN_VALUE;
            pix = PixelData(rand(9, 5), mem_alloc);
            
            pix_to_append = obj.get_pix_with_fake_faccess(rand(9, 23), npix_in_page);
            f = @() pix.append(pix_to_append);
            assertExceptionThrown(f, 'PIXELDATA:append');
        end
        
        function test_append_does_not_edit_calling_instance_if_nargout_eq_1(obj)
            data = rand(9, 30);
            npix_in_page = 11;
            [pix,pix_range] = obj.get_pix_with_fake_faccess(data, npix_in_page);
            pix_to_append = PixelData(rand(9, 5));
            
            pix_out = pix.append(pix_to_append);
            assertEqual(pix.pix_range,pix_range);
            
            assertEqual(pix.num_pixels, size(data, 2));
            pix_data = concatenate_pixel_pages(pix);
            assertEqual(pix_data, data);
        end
        
        %
        function test_append_returns_editied_pix_if_nargout_eq_1(obj)
            % test for filebased pix_range. Has a problem
            pix = PixelData(obj.tst_sqw_file_full_path);
            range1 = pix.pix_range;
            npix_to_append = 5;
            pix_to_append = PixelData(rand(9, npix_to_append));
            range2 =  pix_to_append.pix_range;
            ref_range = [min(range1(1,:),range2(1,:));...
                max(range1(2,:),range2(2,:))];
            out_pix = pix.append(pix_to_append);
            % img_db_range, stored in the file is different from
            % pix(min/max)
            assertEqual(ref_range,out_pix.pix_range);
            
            assertEqual(out_pix.num_pixels, pix.num_pixels + pix_to_append.num_pixels);
            original_pix_data = concatenate_pixel_pages(pix);
            out_pix_data = concatenate_pixel_pages(out_pix);
            assertEqual(out_pix_data, horzcat(original_pix_data, pix_to_append.data));
        end
        
        
        function test_calling_append_with_empty_pixel_data_does_nothing(~)
            pix = PixelData(rand(9, 5));
            range = pix.pix_range;
            pix_to_append = PixelData();
            appended_pix = pix.append(pix_to_append);
            assertEqual(appended_pix.data, pix.data);
            assertEqual(range,pix.pix_range);
        end
        
        function test_copied_pix_that_has_been_appended_to_has_correct_num_pix(~)
            data = rand(9, 30);
            pix = PixelData(data);
            range1 = pix.pix_range;
            num_appended_pix = 5;
            pix_to_append = PixelData(rand(9, num_appended_pix));
            range2 = pix_to_append.pix_range;
            ref_range = [ ...
                min(range1(1,:),range2(1,:));...
                max(range1(2,:),range2(2,:)) ...
                ];
            
            pix.append(pix_to_append);
            assertEqual(ref_range,pix.pix_range);
            
            
            pix_copy = copy(pix);
            assertEqual(pix.num_pixels, size(data, 2) + num_appended_pix);
            assertEqual(pix_copy.num_pixels, size(data, 2) + num_appended_pix);
            assertEqual(ref_range,pix_copy.pix_range);
        end
        
        function test_has_more_is_true_after_appending_page_to_non_file_backed(obj)
            num_pix = 10;
            mem_alloc = (num_pix + 1)*obj.NUM_BYTES_IN_VALUE*obj.NUM_COLS_IN_PIX_BLOCK;
            pix = PixelData(rand(9, 10), mem_alloc);
            range1 = pix.pix_range;
            
            pix_to_append = PixelData(rand(9, 5));
            range2 = pix_to_append.pix_range;
            ref_range = [min(range1(1,:),range2(1,:));...
                max(range1(2,:),range2(2,:))];
            
            pix.append(pix_to_append);
            assertEqual(ref_range,pix.pix_range);
            
            pix.move_to_first_page();
            assertTrue(pix.has_more());
            pix.advance();
            assertFalse(pix.has_more());
            assertEqual(ref_range,pix.pix_range);
        end
        
        function test_error_when_setting_mem_alloc_lt_one_pixel(~)
            pix_size = PixelData.DATA_POINT_SIZE*PixelData.DEFAULT_NUM_PIX_FIELDS;
            
            f = @() PixelData(rand(9, 10), pix_size - 1);
            assertExceptionThrown(f, 'HORACE:PixelData:invalid_argument');
        end
        
        function test_PIXELDATA_raised_if_mem_alloc_argument_is_not_scalar(~)
            mem_alloc = 200e6*ones(1, 2);
            f = @() PixelData(zeros(9, 1), mem_alloc);
            assertExceptionThrown(f, 'HORACE:PixelData:invalid_argument');
        end
        
        function test_move_to_page_loads_given_page_into_memory(obj)
            num_pix = 30;
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            
            npix_in_page = 9;
            [pix,pix_range] = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            for pg_num = [2, 4, 3, 1]
                pg_idx_start = (pg_num - 1)*npix_in_page + 1;
                pg_idx_end = min(pg_num*npix_in_page, num_pix);
                
                pix.move_to_page(pg_num);
                assertEqual(pix.data, data(:, pg_idx_start:pg_idx_end));
            end
            assertEqual(pix.pix_range,pix_range);
        end
        
        function test_move_to_page_throws_if_arg_exceeds_number_of_pages(obj)
            num_pix = 30;
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            f = @() pix.move_to_page(ceil(num_pix/npix_in_page) + 1);
            assertExceptionThrown(f, 'PIXELDATA:move_to_page');
        end
        
        function test_move_to_page_throws_if_arg_less_than_1(obj)
            num_pix = 30;
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            f = @() pix.move_to_page(0);
            assertExceptionThrown(f, 'MATLAB:InputParser:ArgumentFailedValidation');
            
            f = @() pix.move_to_page(-1);
            assertExceptionThrown(f, 'MATLAB:InputParser:ArgumentFailedValidation');
        end
        
        function test_move_to_page_throws_if_arg_is_non_scalar(obj)
            num_pix = 30;
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            f = @() pix.move_to_page([1, 2]);
            assertExceptionThrown(f, 'MATLAB:InputParser:ArgumentFailedValidation');
        end
        
        function test_move_to_page_throws_if_arg_is_not_an_int(obj)
            num_pix = 30;
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            f = @() pix.move_to_page(1.5);
            assertExceptionThrown(f, 'MATLAB:InputParser:ArgumentFailedValidation');
        end
        
        
        function test_get_pixels_retrieves_data_at_absolute_index(obj)
            num_pix = 30;
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            
            start_idx = 9;
            end_idx = 23;
            
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            pix_chunk = pix.get_pixels(start_idx:end_idx);
            ref_range = obj.get_ref_range(data(:,start_idx:end_idx));
            assertEqual(pix_chunk.pix_range,ref_range);
            assertEqual(pix_chunk.data, data(:, start_idx:end_idx));
        end
        
        function test_get_pixels_retrieves_correct_data_at_page_boundary(obj)
            num_pix = 30;
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 10;
            
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            pix_chunk1 = pix.get_pixels(1:3);
            ref_range = obj.get_ref_range(data(:, 1:3));
            
            assertEqual(pix_chunk1.data, data(:, 1:3));
            assertEqual(pix_chunk1.pix_range,ref_range);
            
            
            pix_chunk2 = pix.get_pixels(20);
            ref_range = obj.get_ref_range(data(:, 20));
            
            assertEqual(pix_chunk2.data, data(:, 20));
            assertEqual(pix_chunk2.pix_range,ref_range);
            
            pix_chunk3 = pix.get_pixels(1:1);
            ref_range = obj.get_ref_range(data(:, 1));
            assertEqual(pix_chunk3.data, data(:, 1));
            assertEqual(pix_chunk3.pix_range,ref_range);
        end
        
        function test_get_pixels_gets_all_data_if_full_range_requested(obj)
            num_pix = 30;
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            ref_range = obj.get_ref_range(data(:,1:num_pix));
            pix_chunk = pix.get_pixels(1:num_pix);
            assertEqual(pix_chunk.pix_range,ref_range);
            
            assertEqual(pix_chunk.data, concatenate_pixel_pages(pix));
        end
        
        function test_get_pixels_reorders_output_according_to_indices(obj)
            num_pix = 30;
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            [pix,ref_range] = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            rand_order = randperm(num_pix);
            shuffled_pix = data(:, rand_order);
            pix_out = pix.get_pixels(rand_order);
            
            assertEqual(pix_out.data, shuffled_pix);
            assertEqual(pix_out.pix_range,ref_range);
        end
        
        function test_get_pixels_throws_invalid_arg_if_indices_not_vector(~)
            pix = PixelData();
            f = @() pix.get_pixels(ones(2, 2));
            assertExceptionThrown(f, 'MATLAB:InputParser:ArgumentFailedValidation');
        end
        
        function test_get_pixels_throws_if_range_out_of_bounds(obj)
            num_pix = 30;
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            idx_array = 25:35;
            f = @() pix.get_pixels(idx_array);
            assertExceptionThrown(f, 'PIXELDATA:get_pixels');
        end
        
        function test_get_pixels_throws_if_an_idx_lt_1_with_paged_pix(obj)
            num_pix = 30;
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            idx_array = -1:20;
            f = @() pix.get_pixels(idx_array);
            assertExceptionThrown(f, 'MATLAB:InputParser:ArgumentFailedValidation');
        end
        
        function test_get_pixels_throws_if_an_idx_lt_1_with_in_memory_pix(~)
            in_mem_pix = PixelData(5);
            f = @() in_mem_pix.get_pixels(-1:3);
            assertExceptionThrown(f, 'MATLAB:InputParser:ArgumentFailedValidation');
        end
        
        function test_get_pixels_throws_if_indices_not_positive_int(~)
            pix = PixelData();
            idx_array = 1:0.1:5;
            f = @() pix.get_pixels(idx_array);
            assertExceptionThrown(f, 'MATLAB:InputParser:ArgumentFailedValidation');
        end
        
        function test_paged_pix_get_pixels_can_be_called_with_a_logical(obj)
            num_pix = 30;
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            logical_array = logical(randi([0, 1], [1, 10]));
            ref_range = obj.get_ref_range(data(:,logical_array));
            pix_out = pix.get_pixels(logical_array);
            
            assertEqual(pix_out.data, data(:, logical_array));
            assertEqual(pix_out.pix_range,ref_range);
        end
        
        function test_get_pixels_throws_if_logical_1_index_out_of_range(obj)
            num_pix = 30;
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            logical_array = cat(2, logical(randi([0, 1], [1, num_pix])), true);
            f = @() pix.get_pixels(logical_array);
            
            assertExceptionThrown(f, 'PIXELDATA:get_pixels');
        end
        
        function test_get_pixels_ignores_out_of_range_logical_0_indices(obj)
            num_pix = 30;
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            logical_array = cat(2, logical(randi([0, 1], [1, num_pix])), false);
            pix_out = pix.get_pixels(logical_array);
            
            assertEqual(pix_out.data, data(:, logical_array));
            ref_range = obj.get_ref_range(data(:, logical_array));
            assertEqual(pix_out.pix_range,ref_range);
        end
        
        function test_in_mem_pix_get_pixels_can_be_called_with_a_logical(obj)
            num_pix = 30;
            in_data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            pix = PixelData(in_data);
            
            logical_array = logical(randi([0, 1], [1, 10]));
            pix_out = pix.get_pixels(logical_array);
            
            assertEqual(pix_out.data, pix.data(:, logical_array));
            ref_range = obj.get_ref_range(in_data(:,logical_array));
            assertEqual(pix_out.pix_range,ref_range);
        end
        
        function test_get_pixels_can_handle_repeated_indices(obj)
            num_pix = 30;
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            idx_array = cat(2, randperm(num_pix), randperm(num_pix));
            
            pix_chunk = pix.get_pixels(idx_array);
            assertEqual(pix_chunk.data, data(:, idx_array));
            ref_range = obj.get_ref_range(data(:,idx_array));
            assertEqual(ref_range,pix_chunk.pix_range);
        end
        
        function test_get_pixels_on_file_backed_can_handle_repeated_indices(obj)
            pix = PixelData(obj.tst_sqw_file_full_path, obj.SMALL_PG_SIZE);
            num_pix = pix.num_pixels;
            data = concatenate_pixel_pages(pix);
            
            % Concatenate random permutation of linspaces up to num_pix, this means
            % each index is repeated twice
            idx_array = cat(2, randperm(num_pix), randperm(num_pix));
            
            pix_chunk = pix.get_pixels(idx_array);
            assertEqual(pix_chunk.data, data(:, idx_array));
        end
        
        function test_pg_size_reports_size_of_partially_filled_pg_after_advance(obj)
            num_pix = 30;
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            assertEqual(pix.page_size, npix_in_page);
            
            pix.advance();
            assertEqual(pix.page_size, npix_in_page);
            
            pix.advance();
            num_pix_in_final_pg = 8;
            assertEqual(pix.page_size, num_pix_in_final_pg);
        end
        
        function test_get_data_returns_data_across_pages_by_absolute_index(obj)
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, 30);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            indices = [9:13, 20:24];
            sig_var = pix.get_data({'signal', 'variance'}, indices);
            expected_sig_var = data([obj.SIGNAL_IDX, obj.VARIANCE_IDX], indices);
            
            assertEqual(sig_var, expected_sig_var);
        end
        
        function test_get_data_retrieves_correct_data_at_page_boundary(obj)
            num_pix = 30;
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 10;
            
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            sig = pix.get_data('signal', 1:3);
            assertEqual(sig, data(obj.SIGNAL_IDX, 1:3));
            
            sig2 = pix.get_data('signal', 20);
            assertEqual(sig2, data(obj.SIGNAL_IDX, 20));
            
            sig3 = pix.get_data('signal', 1:1);
            assertEqual(sig3, data(obj.SIGNAL_IDX, 1));
        end
        
        function test_paged_pix_get_data_returns_full_data_range_if_no_idx_arg(obj)
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, 30);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            var_sig = pix.get_data({'variance', 'signal'});
            expected_var_sig = data([obj.VARIANCE_IDX, obj.SIGNAL_IDX], :);
            
            assertEqual(var_sig, expected_var_sig);
        end
        
        function test_paged_pix_get_data_can_be_called_with_a_logical(obj)
            num_pix = 30;
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            logical_array = logical(randi([0, 1], [1, 10]));
            sig_var = pix.get_data({'signal', 'variance'}, logical_array);
            
            expected_sig_var = data([obj.SIGNAL_IDX, obj.VARIANCE_IDX], ...
                logical_array);
            assertEqual(sig_var, expected_sig_var);
        end
        
        function test_get_data_throws_if_logical_1_index_out_of_range(obj)
            num_pix = 30;
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            logical_array = cat(2, logical(randi([0, 1], [1, num_pix])), true);
            f = @() pix.get_data('signal', logical_array);
            
            assertExceptionThrown(f, 'HORACE:PIXELDATA:badsubscript');
        end
        
        function test_get_data_ignores_out_of_range_logical_0_indices(obj)
            num_pix = 30;
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            logical_array = cat(2, logical(randi([0, 1], [1, num_pix])), false);
            var_sig = pix.get_data({'variance', 'signal'}, logical_array);
            
            assertEqual(var_sig, ...
                data([obj.VARIANCE_IDX, obj.SIGNAL_IDX], logical_array));
        end
        
        
        function test_in_mem_pix_get_data_can_be_called_with_a_logical(obj)
            num_pix = 30;
            pix = PixelData(rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix));
            
            logical_array = logical(randi([0, 1], [1, 10]));
            sig_var = pix.get_data({'signal', 'variance'}, logical_array);
            
            assertEqual(sig_var, ...
                pix.data([obj.SIGNAL_IDX, obj.VARIANCE_IDX], logical_array));
        end
        
        function test_get_data_can_handle_repeated_indices(obj)
            num_pix = 30;
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            idx_array = cat(2, randperm(num_pix), randperm(num_pix));
            
            sig_run = pix.get_data({'signal', 'run_idx'}, idx_array);
            assertEqual(sig_run, data([obj.SIGNAL_IDX, obj.RUN_IDX], idx_array));
        end
        
        
        function test_get_data_reorders_output_according_to_indices(obj)
            num_pix = 30;
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            [pix,pix_range] = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            rand_order = randperm(num_pix);
            shuffled_pix = data(:, rand_order);
            sig_var = pix.get_data({'signal', 'variance'}, rand_order);
            
            assertEqual(sig_var, ...
                shuffled_pix([obj.SIGNAL_IDX, obj.VARIANCE_IDX], :));
            assertEqual(pix.pix_range,pix_range);
        end
        
        function test_get_data_throws_invalid_arg_if_indices_not_vector(~)
            pix = PixelData();
            f = @() pix.get_data('signal', ones(2, 2));
            assertExceptionThrown(f, 'MATLAB:InputParser:ArgumentFailedValidation');
        end
        
        function test_get_data_throws_if_range_out_of_bounds(obj)
            num_pix = 30;
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            idx_array = 25:35;
            f = @() pix.get_data('signal', idx_array);
            assertExceptionThrown(f, 'PIXELDATA:get_data');
        end
        
        function test_get_data_throws_if_an_idx_lt_1_with_paged_pix(obj)
            num_pix = 30;
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            idx_array = -1:20;
            f = @() pix.get_data('signal', idx_array);
            assertExceptionThrown(f, 'MATLAB:InputParser:ArgumentFailedValidation');
        end
        
        function test_get_data_throws_if_an_idx_lt_1_with_in_memory_pix(~)
            in_mem_pix = PixelData(5);
            f = @() in_mem_pix.get_data('signal', -1:3);
            assertExceptionThrown(f, 'MATLAB:InputParser:ArgumentFailedValidation');
        end
        
        function test_get_data_throws_if_indices_not_positive_int(~)
            pix = PixelData();
            idx_array = 1:0.1:5;
            f = @() pix.get_data('signal', idx_array);
            assertExceptionThrown(f, 'MATLAB:InputParser:ArgumentFailedValidation');
        end
        
        function test_base_page_size_is_DEFAULT_PAGE_SIZE_by_default(~)
            pix = PixelData();
            bytes_in_pixel = PixelData.DEFAULT_NUM_PIX_FIELDS*PixelData.DATA_POINT_SIZE;
            expected_num_pix = floor(PixelData.DEFAULT_PAGE_SIZE/bytes_in_pixel);
            assertEqual(pix.base_page_size, expected_num_pix);
        end
        
        function test_get_pixels_can_load_from_mix_of_dirty_and_clean_pages(obj)
            pix = PixelData(obj.tst_sqw_file_full_path, obj.SMALL_PG_SIZE);
            pix.advance();  % pg 1 is clean
            % Set all signals in page 2 to 11
            pix.signal = 11;
            pix.advance();  % pg 2 is dirty
            pix.advance();  % pg 3 is clean
            % Set all signals in page 4 to 12
            pix.signal = 12;
            pix.advance();  % advance to save pixels to tmp file (pg 4 is dirty)
            
            pg_size = pix.base_page_size;
            % Set a range spanning into the first and second page and half of the
            % 4th page
            pix_range = [5:(pg_size + 100), ...
                (3*pg_size + 4):(3*pg_size + floor(pg_size/2))];
            new_pix = pix.get_pixels(pix_range);
            
            % Load the whole file into a PixelData object, set the corresponding
            % pixels to 11 and 12 as above
            in_mem_pix = PixelData(obj.tst_sqw_file_full_path);
            in_mem_pix.signal((pg_size + 1):(2*pg_size)) = 11;
            in_mem_pix.signal((3*pg_size + 1):(4*pg_size)) = 12;
            expected_pix = PixelData(in_mem_pix.data(:, pix_range));
            
            assertEqualToTol(new_pix, expected_pix);
        end
        
        function test_get_pixels_can_load_clean_and_dirty_pix_out_of_order(obj)
            % See test_get_pixels_can_load_from_mix_of_dirty_and_clean_pages for
            % relevant test explanation
            pix = PixelData(obj.tst_sqw_file_full_path, obj.SMALL_PG_SIZE);
            pix.advance();
            pix.signal = 11;
            pix.advance();
            pix.signal = 12;
            pix.advance();
            
            pg_size = pix.base_page_size;
            pix_range = pix.num_pixels:-1:1;  % pix range in reverse order
            new_pix = pix.get_pixels(pix_range);
            
            in_mem_pix = PixelData(obj.tst_sqw_file_full_path);
            in_mem_pix.signal(pg_size + 1:2*pg_size) = 11;
            in_mem_pix.signal(2*pg_size + 1:3*pg_size) = 12;
            expected_pix = PixelData(in_mem_pix.data(:, pix_range));
            
            assertEqualToTol(new_pix, expected_pix);
        end
        
        function test_get_pixels_can_load_clean_and_dirty_pix_with_duplicates(obj)
            % See test_get_pixels_can_load_from_mix_of_dirty_and_clean_pages for
            % relevant test explanation
            pix = PixelData(obj.tst_sqw_file_full_path, obj.SMALL_PG_SIZE);
            assertTrue(pix.page_size < pix.num_pixels);  % make sure we're paging
            pix.advance();
            pix.signal = 11;
            pix.advance();
            
            pg_size = pix.base_page_size;
            % Repeat each index from 1 to the page size 3 times
            pix_range = repelem(1:3*pg_size, 3);
            new_pix = pix.get_pixels(pix_range);
            
            in_mem_pix = PixelData(obj.tst_sqw_file_full_path);
            in_mem_pix.signal(pg_size + 1:2*pg_size) = 11;
            expected_pix = PixelData(in_mem_pix.data(:, pix_range));
            
            assertEqualToTol(new_pix, expected_pix);
        end
        
        function test_get_pixels_can_load_clean_and_dirty_pix_cached_page_dirty(obj)
            % See test_get_pixels_can_load_from_mix_of_dirty_and_clean_pages for
            % relevant test explanation
            pix = PixelData(obj.tst_sqw_file_full_path, obj.SMALL_PG_SIZE);
            assertTrue(pix.page_size < pix.num_pixels);  % make sure we're paging
            pix.advance();
            pix.signal = 11;
            
            % Do not advance past edited page, changes only exist in cache and not
            % in temporary files
            pg_size = pix.base_page_size;
            
            % Repeat each index from 1 to the page size 3 times
            pix_range = repelem(1:3*pg_size, 3);
            new_pix = pix.get_pixels(pix_range);
            
            in_mem_pix = PixelData(obj.tst_sqw_file_full_path);
            in_mem_pix.signal(pg_size + 1:2*pg_size) = 11;
            expected_pix = PixelData(in_mem_pix.data(:, pix_range));
            
            assertEqualToTol(new_pix, expected_pix);
        end
        
        function test_get_pixels_correct_if_all_pages_dirty(~)
            data = rand(9, 45);
            mem_alloc = 8*9*15;
            pix = PixelData(zeros(9, 0), mem_alloc);
            for i = 1:3
                a = (i - 1)*15 + 1;
                b = i*15;
                pix.append(PixelData(data(:, a:b)));
            end
            
            pix_idx = [12:17, 28:33, 44];
            new_pix = pix.get_pixels(pix_idx);
            
            expected_pix = PixelData(data(:, pix_idx));
            assertEqualToTol(new_pix, expected_pix, 'reltol', 1e-5);
        end
        function test_calling_advance_with_nosave_discards_cached_changes(obj)
            data = zeros(9, 30);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);

            % set all u1 values in each page to 1
            pix.u1 = 1;
            pix.advance('nosave', true);  % move to second page
            pix.move_to_first_page();

            assertEqual(pix.u1, zeros(1, npix_in_page));
        end

        function test_set_data_sets_fields_with_given_values(~)
            pix = PixelData(30);
            new_data = ones(3, 7);
            fields = {'run_idx', 'signal', 'variance'};
            idxs = [4, 3, 9, 24, 29, 10, 11];
            pix.set_data(fields, new_data, idxs);

            assertEqual(pix.get_data(fields, idxs), new_data);

            % Check other fields/indices unchanged
            non_edited_idxs = 1:pix.num_pixels;
            non_edited_idxs(idxs) = [];
            assertEqual(pix.data(:, non_edited_idxs), zeros(9, 23));
        end

        function test_set_data_sets_single_fields_with_given_values(~)
            pix = PixelData(30);
            new_data = ones(1, 7);
            field = 'run_idx';
            idxs = [4, 3, 9, 24, 29, 10, 11];
            pix.set_data(field, new_data, idxs);

            assertEqual(pix.get_data(field, idxs), new_data);

            % Check other fields/indices unchanged
            non_edited_idxs = 1:pix.num_pixels;
            non_edited_idxs(idxs) = [];
            assertEqual(pix.data(:, non_edited_idxs), zeros(9, 23));
        end

        function test_set_data_sets_fields_with_given_values_pix_filebacked(obj)
            num_pix = 30;
            data = zeros(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_per_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_per_page);

            new_data = ones(3, 7);
            fields = {'run_idx', 'signal', 'variance'};
            idxs = [4, 3, 9, 24, 29, 10, 11];
            pix.set_data(fields, new_data, idxs);

            assertEqual(pix.get_data(fields, idxs), new_data);

            % Check other fields/indices unchanged
            non_edited_idxs = 1:pix.num_pixels;
            non_edited_idxs(idxs) = [];
            unedited_pix = pix.get_pixels(non_edited_idxs);
            assertEqual(unedited_pix.data, zeros(9, 23));
        end

        function test_set_data_errors_if_data_nrows_ne_to_num_fields(~)
            pix = PixelData(30);
            fields = {'run_idx', 'signal', 'variance'};
            new_data = ones(numel(fields) + 1, 7);
            idxs = [4, 3, 9, 24, 29, 10, 11];
            f = @() pix.set_data(fields, new_data, idxs);
            assertExceptionThrown(f, 'HORACE:PixelData:invalid_argument');
        end

        function test_set_data_errors_if_data_ncols_ne_to_num_indices(~)
            pix = PixelData(30);
            fields = {'run_idx', 'signal', 'variance'};
            idxs = [4, 3, 9, 24, 29, 10, 11];
            new_data = ones(numel(fields), numel(idxs) - 1);
            f = @() pix.set_data(fields, new_data, idxs);
            assertExceptionThrown(f, 'HORACE:PixelData:invalid_argument');
        end

        function test_set_data_sets_fields_with_given_values_with_logical_idxs(~)
            pix = PixelData(30);
            new_data = ones(3, 7);
            fields = {'run_idx', 'signal', 'variance'};
            idxs = [4, 3, 9, 24, 29, 10, 11];
            logical_idxs = zeros(1, 30, 'logical');
            logical_idxs(idxs) = true;
            pix.set_data(fields, new_data, logical_idxs);

            assertEqual(pix.get_data(fields, idxs), new_data);

            % Check other fields/indices unchanged
            non_edited_idxs = 1:pix.num_pixels;
            non_edited_idxs(idxs) = [];
            assertEqual(pix.data(:, non_edited_idxs), zeros(9, 23));
        end

        function test_set_data_sets_all_if_abs_pix_indices_not_given_filebacked(obj)
            num_pix = 30;
            data = zeros(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_per_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_per_page);

            new_data = ones(3, num_pix);
            fields = {'run_idx', 'signal', 'variance'};
            pix.set_data(fields, new_data);

            assertEqual(pix.get_data(fields), new_data);
        end

        function test_set_data_sets_all_if_abs_pix_indices_not_given(~)
            num_pix = 30;
            pix = PixelData(num_pix);
            new_data = ones(3, num_pix);
            fields = {'run_idx', 'signal', 'variance'};
            pix.set_data(fields, new_data);

            assertEqual(pix.get_data(fields), new_data);
        end
        % -- Helpers --
        function [pix,pix_range] = get_pix_with_fake_faccess(obj, data, npix_in_page)
            pix_range = [min(data(1:4,:),[],2),max(data(1:4,:),[],2)]';
            faccess = FakeFAccess(data);
            % give it a real file path to trick code into thinking it exists
            faccess = faccess.set_filepath(obj.tst_sqw_file_full_path);
            mem_alloc = npix_in_page*obj.NUM_BYTES_IN_VALUE*obj.NUM_COLS_IN_PIX_BLOCK;
            pix = PixelData(faccess, mem_alloc);
        end
        
        function do_pixel_data_loop_with_f(obj, func, data)
            % func should be a function handle, it is evaluated within a
            % while-advance block over some pixel data
            faccess = FakeFAccess(data);
            
            pix_in_page = 11;
            mem_alloc = pix_in_page*obj.NUM_BYTES_IN_VALUE*obj.NUM_COLS_IN_PIX_BLOCK;
            pix = PixelData(faccess, mem_alloc);
            
            func(pix, 0)
            iter = 1;
            while pix.has_more()
                pix.advance();
                func(pix, iter)
                iter = iter + 1;
            end
        end
        
    end
    
    methods (Static)
        
        function advance_pix(pix, niters)
            % Advance the pixel pages by 'niters'
            for i = 1:niters
                pix.advance();
            end
        end
        
    end
    
end
