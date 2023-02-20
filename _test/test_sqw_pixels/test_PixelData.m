classdef test_PixelData < TestCase & common_pix_class_state_holder

    properties

        SMALL_PG_SIZE = 1e5;  % 10,000 pix
        ALL_IN_MEM_PG_SIZE = 1e12;

        raw_pix_data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 10);
        raw_pix_range;
        tst_sqw_file_full_path = '';
        this_dir = fileparts(mfilename('fullpath'));

        pixel_data_obj;
        pix_data_from_file;
        pix_data_from_faccess;
        pix_fields = {'u1', 'u2', 'u3', 'dE', 'coordinates', 'q_coordinates', ...
            'run_idx', 'detector_idx', 'energy_idx', 'signal', ...
            'variance'};

        warning_cache;
    end

    properties (Constant)
        NUM_BYTES_IN_VALUE = sqw_binfile_common.FILE_PIX_SIZE;
        NUM_COLS_IN_PIX_BLOCK = PixelDataBase.DEFAULT_NUM_PIX_FIELDS;
        BYTES_IN_PIXEL = sqw_binfile_common.FILE_PIX_SIZE;
        RUN_IDX = 5;
        SIGNAL_IDX = 8;
        VARIANCE_IDX = 9;
        tol = 1e-6;
    end

    methods(Static, Access=private)

        function [pix_data,data_range] = get_random_pix_data_(rows)
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, rows);
            pix_data = PixelDataMemory(data);
            data_range = pix_data.data_range;

        end

        function ref_range = get_ref_range(data)
            ref_range = [min(data(1:4, :),[],2),...
                max(data(1:4, :),[],2)]';
        end

    end

    methods

        function obj = test_PixelData(~)
            obj = obj@TestCase('test_PixelData');
            obj.warning_cache = warning('off','HORACE:old_file_format');

            obj.raw_pix_range = obj.get_ref_range(obj.raw_pix_data);

            pths = horace_paths;
            source_sqw_file = fullfile(pths.test_common, 'sqw_1d_1.sqw');

            test_sqw_file_full_path = fullfile(tmp_dir, 'sqw_1d_1.sqw');
            copyfile(source_sqw_file,test_sqw_file_full_path);

            %modify_pix_ranges(test_sqw_file_full_path);
            obj.tst_sqw_file_full_path = test_sqw_file_full_path;
            % Construct an object from raw data
            obj.pixel_data_obj = PixelDataBase.create(obj.raw_pix_data);
            % Construct an object from a file
            obj.pix_data_from_file = PixelDataFileBacked(obj.tst_sqw_file_full_path);
            % Construct an object from a file accessor
            f_accessor = sqw_formats_factory.instance().get_loader(obj.tst_sqw_file_full_path);
            obj.pix_data_from_faccess = PixelDataFileBacked(f_accessor);
            % Construct an object from file accessor with small page size

        end

        function delete(obj)
            warning(obj.warning_cache);
        end

        % --- Tests for in-memory operations ---
        function test_default_construction_sets_empty_pixel_data(~)
            pix_data = PixelDataBase.create();
            assertEqual(pix_data.data, zeros(9, 0));
            assertEqual(pix_data.pix_range,[inf,inf,inf,inf;-inf,-inf,-inf,-inf])
            assertEqual(pix_data.data_range,PixelDataBase.EMPTY_RANGE)
        end

        function test_PixelData_raised_on_construction_with_data_with_lt_9_cols(~)
            f = @() PixelDataBase.create(ones(3, 3));
            assertExceptionThrown(f, 'HORACE:PixelDataMemory:invalid_argument');
        end

        function test_PixelData_raised_on_construction_with_data_with_gt_9_cols(~)
            f = @() PixelDataBase.create(ones(10, 3));
            assertExceptionThrown(f, 'HORACE:PixelDataMemory:invalid_argument');
        end

        function test_coordinates_returns_empty_array_if_pixel_data_empty(~)
            pix_data = PixelDataBase.create();
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
            assertEqual(pix_data_obj.data_range, range);
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
            range = pix_data_obj.data_range;
            assertEqual(ref_range,range);
            assertEqual(pix_data_obj.data_range,range)
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
            range = pix_data_obj.data_range;
            assertEqual(ref_range,range);
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
            range = pix_data_obj.data_range;
            assertEqual(ref_range,range);
        end

        function test_q_coordinates_returns_first_3_dims_of_coordinates(obj)
            q_coords = obj.pixel_data_obj.q_coordinates;
            assertEqual(q_coords, obj.pixel_data_obj.q_coordinates);
        end

        function test_setting_q_coordinates_updates_u1_u2_and_u3(obj)
            [pix_data_obj,range] = obj.get_random_pix_data_(10);
            pix_data_obj.q_coordinates = ones(3, 10);
            assertEqual(pix_data_obj.u1, ones(1, 10));
            assertEqual(pix_data_obj.u2, ones(1, 10));
            assertEqual(pix_data_obj.u3, ones(1, 10));
            assertEqual(pix_data_obj.pix_range(:,1:3),ones(2,3));
            assertEqual(pix_data_obj.data_range(:,4:9),range(:,4:9));
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

        function test_PixelData_error_raised_if_setting_data_with_lt_9_cols(~)
            f = @(x) PixelDataBase.create(zeros(x, 10));
            for i = [1, 5]
                assertExceptionThrown(@() f(i), 'HORACE:PixelDataMemory:invalid_argument');
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
            assertExceptionThrown(f, 'HORACE:PixelDataBase:invalid_argument');
        end

        function test_error_raised_if_setting_coordinates_with_wrong_num_cols(obj)
            num_rows = 10;
            pix_data_obj = obj.get_random_pix_data_(num_rows);

            function set_coordinates(data)
                pix_data_obj.coordinates = data;
            end

            new_coord_data = ones(3, num_rows);
            f = @() set_coordinates(new_coord_data);
            assertExceptionThrown(f, 'HORACE:PixelDataBase:invalid_argument');
        end

        function test_PixelData_object_with_underlying_data_is_not_empty(obj)
            assertFalse(obj.pixel_data_obj.num_pixels == 0);
        end

        function test_default_PixelData_object_is_empty(~)
            pix_data_obj = PixelDataBase.create();
            assertEqual(pix_data_obj.num_pixels,0);
        end

        function test_empty_structure_creates_empty_membased(~)
            s = struct();
            to = PixelDataBase.create(s);
            assertTrue(isa(to,'PixelDataMemory'))
            assertEqual(to.num_pixels,0)
        end

        function test_PixelData_error_if_constructed_with_cell_array(~)
            s = {'a', 1};
            f = @() PixelDataBase.create(s);
            assertExceptionThrown(f, 'HORACE:PixelDataBase:invalid_argument');
        end

        function test_PixelData_set_data_all(~)
            pix_data_obj = PixelDataBase.create();
            data = zeros(9,1);
            pix_data_obj = pix_data_obj.set_fields(data,'all');
            assertEqual(pix_data_obj.num_pixels,1);
            assertEqual(pix_data_obj.coordinates,zeros(4,1));

        end

        function test_PixelData_set_data_all_wrong_size(~)
            pix_data_obj = PixelDataBase.create();
            data = zeros(4,1);
            f = @()set_fields(pix_data_obj,data,'all');
            assertExceptionThrown(f, 'HORACE:PixelDataBase:invalid_argument');

        end

        function test_PixelData_error_if_data_set_with_non_numeric_type(~)
            pix_data_obj = PixelDataBase.create();

            function set_data(data)
                pix_data_obj.data = data;
            end

            f = @() set_data({1, 'abc'});
            assertExceptionThrown(f, 'HORACE:PixelDataMemory:invalid_argument');
        end

        function test_num_pix_returns_the_number_of_elements_in_the_data(obj)
            assertEqual(obj.pixel_data_obj.num_pixels*PixelDataBase.DEFAULT_NUM_PIX_FIELDS,...
                numel(obj.pixel_data_obj.data));
        end

        function test_can_construct_from_another_PixelData_object(obj)
            pixel_data_obj_copy = PixelDataBase.create(obj.pixel_data_obj);
            assertEqual(pixel_data_obj_copy.data, obj.pixel_data_obj.data);
        end

        function test_get_fields_returns_coordinates_for_given_index_range(obj)
            pix_data_obj = obj.get_random_pix_data_(10);
            coords = pix_data_obj.get_fields({'coordinates'}, 2:6);
            assertEqual(coords, pix_data_obj.coordinates(:, 2:6));
        end

        function test_get_fields_returns_multiple_fields_for_given_index_range(obj)
            pix_data_obj = obj.get_random_pix_data_(10);
            coord_sig = pix_data_obj.get_fields({'coordinates', 'signal'}, 4:9);
            expected_coord_sig = [pix_data_obj.coordinates(:, 4:9); ...
                pix_data_obj.signal(4:9)];
            assertEqual(coord_sig, expected_coord_sig);
        end

        function test_get_fields_returns_full_pixel_range_if_no_range_given(obj)
            pix_data_obj = obj.get_random_pix_data_(10);
            coord_sig = pix_data_obj.get_fields({'coordinates', 'signal'});
            expected_coord_sig = [pix_data_obj.coordinates; pix_data_obj.signal];
            assertEqual(coord_sig, expected_coord_sig);
        end

        function test_get_fields_allows_data_retrieval_for_single_field(obj)
            for i = 1:numel(obj.pix_fields)
                field_data = obj.pixel_data_obj.get_fields(obj.pix_fields{i});
                assertEqual(field_data, obj.pixel_data_obj.(obj.pix_fields{i}));
            end
        end

        function test_get_fields_throws_PixelData_on_non_valid_field_name(obj)
            f = @() obj.pixel_data_obj.get_fields('not_a_field');
            assertExceptionThrown(f, 'HORACE:PixelData:invalid_argument');
        end

        function test_get_fields_orders_columns_by_input_cell_array(obj)
            pix_data_obj = obj.get_random_pix_data_(10);

            data_subset = pix_data_obj.get_fields({'detector_idx', 'signal', 'run_idx'});

            assertEqual(data_subset(1, :), pix_data_obj.detector_idx);
            assertEqual(data_subset(2, :), pix_data_obj.signal);
            assertEqual(data_subset(3, :), pix_data_obj.run_idx);
        end

        function test_cat_combines_given_PixelData_objects(obj)
            pix_data_obj1 = obj.get_random_pix_data_(10);
            pix_data_obj2 = obj.get_random_pix_data_(5);

            combined_pix = PixelDataBase.cat(pix_data_obj1, pix_data_obj2);

            assertEqual(combined_pix.num_pixels, 15);
            assertEqual(combined_pix.data, ...
                horzcat(pix_data_obj1.data, pix_data_obj2.data));
        end

        function test_get_pixels_returns_PixelData_obj_with_given_pix_indices(~)
            data = rand(9, 10);
            pix = PixelDataBase.create(data);
            sub_pix = pix.get_pixels([3, 5, 7]);
            assertTrue(isa(pix, 'PixelDataBase'));
            assertEqual(sub_pix.data, data(:, [3, 5, 7]));
        end

        function test_get_pixels_returns_PixelData_with_equal_num_cols(obj)
            pix = obj.get_random_pix_data_(10);
            orignal_size = size(pix.data, 1);
            sub_pix = pix.get_pixels(1:5);
            assertEqual(size(sub_pix.data, 1), orignal_size);
        end

        function test_load_obj_returns_equivalent_object(~)
            tobj = PixelDataBase.create(ones(9, 10));
            obj_s = tobj.saveobj();
            pix = PixelDataBase.loadobj(obj_s);
            assertEqual(pix, tobj);
        end

        function test_construction_with_int_fills_underlying_data_with_zeros(~)
            npix = 20;
            pix = PixelDataBase.create(npix);
            assertEqual(pix.num_pixels, npix);
            assertEqual(pix.data, zeros(9, npix));
            assertEqual(pix.variance, zeros(1, npix));
        end

        function test_construction_with_float_raises_PixelData_error(~)
            f = @() PixelDataBase.create(1.2);
            assertExceptionThrown(f, 'HORACE:PixelDataMemory:invalid_argument');
        end

        function test_construction_with_file_path_sets_file_path_on_object(obj)
            assertEqual(obj.pix_data_from_file.full_filename, obj.tst_sqw_file_full_path);
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
            f = @() PixelDataBase.create(file_path);
            assertExceptionThrown(f, 'HORACE:file_io:runtime_error');
        end

        function test_construction_with_faccess_populates_data_from_file(obj)
            assertFalse(isempty(obj.pix_data_from_faccess));
            expected_signal_chunk = [0, 0, 0, 0, 0483.5, 4463.0, 1543.0, 0, 0, 0];
            assertEqual(obj.pix_data_from_faccess.signal(9825:9834), ...
                expected_signal_chunk);
        end

        function test_construction_with_faccess_sets_file_path(obj)
            assertEqual(obj.pix_data_from_faccess.full_filename, obj.tst_sqw_file_full_path);
        end

        function test_page_size_is_set_after_getter_call_when_given_as_argument(obj)
            expected_page_size = obj.SMALL_PG_SIZE;
            hc = hor_config;
            mem_ch_size = hc.mem_chunk_size;
            clOb = onCleanup(@()set(hc,'mem_chunk_size',mem_ch_size));
            hc.mem_chunk_size = obj.SMALL_PG_SIZE;
            % the first page is loaded on access, so this first assert which accesses
            % .variance is necessary to set pix.page_size
            assertEqual(size(obj.pix_data_from_file.variance), ...
                [1, obj.pix_data_from_file.page_size]);
            assertEqual(obj.pix_data_from_file.page_size, expected_page_size);
        end

%         function test_calling_getter_returns_data_for_single_page(obj)
%             data = rand(9, 30);
%             npix_in_page = 11;
%             pix = obj.get_pix_with_fake_faccess(data);
%             assertEqual(size(pix.signal), [1, pix.page_size]);
%             assertElementsAlmostEqual(pix.signal, data(8, 1:11),'relative',obj.tol);
%         end

%         function test_calling_get_fields_returns_data_for_single_page(obj)
%             data = rand(9, 30);
%             npix_in_page = 11;
%             pix = obj.get_pix_with_fake_faccess(data);
%             sig_var = pix.get_fields({'signal', 'variance'}, 3:8);
%             assertElementsAlmostEqual(sig_var, data(8:9, 3:8),'relative',obj.tol);
%         end

        function test_data_values_are_not_affected_by_changes_in_copies(~)
            n_rows = 5;
            p1 = PixelDataBase.create(ones(9, n_rows));
            p2 = copy(p1);
            p2.u1 = zeros(1, n_rows);
            assertEqual(p2.u1, zeros(1, n_rows));
            assertEqual(p1.u1, ones(1, n_rows));
        end

%         function test_number_of_pixels_in_page_matches_memory_usage_size(obj)
%             data = rand(9, 30);
%             npix_in_page = 11;
%             pix = obj.get_pix_with_fake_faccess(data);
%             pix.u1;
%             assertEqual(size(pix.data, 2), npix_in_page);
%         end

%         function test_has_more_true_if_there_are_subsequent_pixels_in_file(obj)
%             data = rand(9, 12);
%             npix_in_page = 11;
%             pix = obj.get_pix_with_fake_faccess(data);
%             assertTrue(pix.has_more());
%         end
%
%         function test_has_more_false_if_all_data_in_page(obj)
%             data = rand(9, 11);
%             npix_in_page = 11;
%             pix = obj.get_pix_with_fake_faccess(data);
%             assertFalse(pix.has_more());
%         end
%
%         function test_has_more_false_if_all_data_created_in_memory(~)
%             data = rand(9, 30);
%             pix = PixelDataMemory(data);
%             assertFalse(pix.has_more());
%         end

%         function test_advance_raises_PixelData_if_at_end_of_data(obj)
%             npix = 30;
%             data = rand(9, npix);
%             npix_in_page = 11;
%             pix = obj.get_pix_with_fake_faccess(data);
%
%             f = @() obj.advance_pix(pix, floor(npix/npix_in_page + 1));
%             assertExceptionThrown(f, 'PIXELDATA:move_to_page');
%         end

        function test_loop_to_sum_signal_data(obj)
            data = randi([0, 99], 9, 30);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data);

            signal_sum = 0;
            for i = 1:pix.num_pages
                pix.page_num = i;
                signal_sum = signal_sum + sum(pix.signal);
            end

            assertEqual(signal_sum, sum(data(8, :)));
        end

        function test_page_size_returns_size_of_data_held_in_memory(obj)
            pix = obj.get_random_pix_data_(10);
            assertEqual(pix.page_size, 10);
        end

        function test_empty_PixelData_object_has_page_size_zero(~)
            pix = PixelDataBase.create();
            assertEqual(pix.page_size, 0);
        end

%         function test_constructing_from_PixelData_with_valid_file_inits_faccess(obj)
%             new_pix = PixelDataFileBacked(obj.pix_data_small_page);
%             assertEqual(new_pix.file_path, obj.tst_sqw_file_full_path);
%             assertEqual(new_pix.num_pixels, obj.pix_data_small_page.num_pixels);
%             assertEqual(new_pix.signal, obj.pix_data_small_page.signal);
%             assertTrue(new_pix.has_more());
%         end

%         function test_move_to_first_page_resets_to_first_page_in_file(obj)
%             data = rand(9, 30);
%             npix_in_page = 11;
%             pix = obj.get_pix_with_fake_faccess(data);
%             pix.advance();
%             assertElementsAlmostEqual(pix.u1, data(1, 12:22),'relative',obj.tol);  % currently on the second page
%             pix.move_to_first_page();
%             assertElementsAlmostEqual(pix.u1, data(1, 1:11),'relative',obj.tol);  % should be back to the first page
%         end

        function test_move_to_first_page_keeps_data_if_pix_not_file_backed(obj)
            pix = obj.get_random_pix_data_(30);
            u1 = pix.u1;
            pix.move_to_first_page();
            assertEqual(pix.u1, u1);
        end

        function test_instance_has_page_size_after_construction(~)
            data = rand(9, 10);
            faccess = FakeFAccess(data);
            pix = PixelDataBase.create(faccess);
            assertEqual(pix.page_size, 10);
        end

        function test_editing_a_field_loads_page(obj)
            data = rand(9, 10);
            faccess = FakeFAccess(data);
            for i = 1:numel(obj.pix_fields)
                pix = PixelDataBase.create(faccess);
                pix.(obj.pix_fields{i}) = 1;
                assertEqual(pix.page_size, 10);
            end
        end

%         function test_setting_file_backed_pixels_preserves_changes_after_advance(obj)
%             data = rand(9, 30);
%             npix_in_page = 11;
%             pix = obj.get_pix_with_fake_faccess(data);
%
%             pix.move_to_first_page();
%             pix.u1 = 1;  % sets page 1 of u1 to all ones
%             pix.dump_all_pixels_(); % Save changes
%             pix.move_to_page(2);  % move to second page
%             assertElementsAlmostEqual(pix.u1, data(1, (npix_in_page + 1):(2*npix_in_page)),...
%                 'relative',obj.tol);
%
%             pix.move_to_page(1);
%             assertEqual(pix.u1, ones(1, npix_in_page),'relative',obj.tol);
%         end

%         function test_dirty_pix_tmp_files_are_deleted_when_pix_out_of_scope(obj)
%             old_rng_state = rng();
%             clean_up = onCleanup(@() rng(old_rng_state));
%             fixed_seed = 774015;
%             rng(fixed_seed, 'twister');  % this seed gives an expected object_id_ = 53801
%             expected_tmp_file = fullfile( ...
%                 get(parallel_config, 'working_directory'), ...
%                 'sqw_pix538011426.tmp_sqw' ...
%                 );
%
%             function do_pix_creation_and_delete()
%                 data = rand(9, 30);
%
%                 pix = obj.get_pix_with_fake_faccess(data);
%
%                 pix.u1 = 1;
%                 assertTrue( ...
%                     is_file(expected_tmp_file), ...
%                     sprintf('Temp file ''%s'' not created', expected_tmp_file) ...
%                     );
%             end
%
%             do_pix_creation_and_delete();
%             pause(0.2)  % let the file system catch up
%             assertFalse(is_file(expected_tmp_file), ...
%                 'Temp file not deleted');
%         end

        function test_set_fields_sets_all(obj)
            data = zeros(9, 30);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data);

            % set all u1 values in each page to 1
            pix.set_fields(1, 'u1');

            % check all u1 values are 1
            for i = 1:pix.num_pages
                pix.page_num = i;
                assertEqual(pix.u1, ones(1, pix.page_size));
            end
        end

        function test_set_fields_with_nonscalar_data_sets_Ndata(obj)
            data = zeros(9, 30);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data);

            % set all u1 values in each page to 1
            pix.set_fields(1, 'u1');

            % check all u1 values are 1
            for i = 1:pix.num_pages
                pix.page_num = i;
                assertEqual(pix.u1, ones(1, pix.page_size));
            end
        end


%         function test_correct_values_returned_with_mix_of_clean_and_dirty_pages(obj)
%             data = zeros(9, 30);
%
%             pix = obj.get_pix_with_fake_faccess(data);
%
%             % set coordinates of page 1 and 3 to all ones
%             pix.u1 = 1;
%             pix.dump_all_pixels_();
%             pix.move_to_page(3);
%             pix.u1 = 1;
%             pix.dump_all_pixels_();
%
%             pix.move_to_first_page();
%
%             assertEqual(pix.u1, ones(1, pix.page_size));
%             pix.advance();
%             assertEqual(pix.u1, zeros(1, pix.page_size));
%             pix.advance();
%             assertEqual(pix.u1, ones(1, pix.page_size));
%         end

%         function test_you_cannot_set_page_of_data_with_smaller_sized_array(obj)
%             data = zeros(9, 30);
%             pix = obj.get_pix_with_fake_faccess(data);
%
%             function set_pix(data)
%                 pix.data = data;
%             end
%
%             f = @() set_pix(ones(9, 10));
%             assertExceptionThrown(f, 'MATLAB:incorrectSize');
%         end
%
%         function test_you_cannot_set_page_of_data_with_larger_sized_array(obj)
%             data = zeros(9, 30);
%             pix = obj.get_pix_with_fake_faccess(data);
%
%             function set_pix(data)
%                 pix.data = data;
%             end
%
%             f = @() set_pix(ones(9, 20));
%             assertExceptionThrown(f, 'MATLAB:incorrectSize');
%         end

        function test_num_pixels_is_a_double_if_faccess_returns_uint(~)
            npix = 30;
            data = rand(9, npix);
            faccess = FakeFAccess(data);
            faccess = faccess.set_npixels(uint64(npix));

            pix = PixelDataBase.create(faccess);
            assertEqual(class(pix.num_pixels), 'double');
        end

        function test_num_pixels_is_a_double_if_data_in_memory(obj)
            assertEqual(class(obj.pixel_data_obj.num_pixels), 'double');
        end

        function test_num_pixels_is_a_double_if_more_than_one_page_of_data(obj)
            assertEqual(class(obj.pix_data_from_file.num_pixels), 'double');
        end

        function test_copy_on_same_page_as_original_when_more_than_1_page(obj)
            pix_original = PixelDataBase.create(obj.tst_sqw_file_full_path);
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
            skipTest('Re #928 Should we allow writable PixelDataFileBacked?')
            pix_original = PixelDataFileBacked(obj.tst_sqw_file_full_path);
            pix_original.signal = 1;

            pix_copy = copy(pix_original);
            assertEqual(pix_copy.data, pix_original.data);
            for i=1:pix_original.num_pages
                % we shouldn't enter here, but we should check the same API for
                % data with > 1 page works for single page
                pix_original.page_num = i;
                pix_copy.page_num = i;
                assertEqual(pix_copy.data, pix_original.data);
            end

        end

        function test_changes_to_original_persistent_in_copy_if_1_page_in_file(obj)
            skipTest('Re #928 Should we allow writable PixelDataFileBacked?')
            pix_original = PixelDataFileBacked(obj.tst_sqw_file_full_path);
            pix_original.signal = 1;

            pix_copy = copy(pix_original);

            assertEqual(pix_copy.data, pix_original.data);
        end

        function test_changes_to_orig_persistent_in_copy(obj)
            skipTest('Re #928 Should we allow writable PixelDataFileBacked?')
            pix_original = PixelDataFileBacked(obj.tst_sqw_file_full_path);
            pix_original.signal = 1;

            pix_copy = copy(pix_original);

            assertEqual(pix_copy.data, pix_original.data);
            for i=1:pix_original.num_pages
                % we shouldn't enter here, but we should check the same API for
                % data with > 1 page works for single page
                pix_original.page_num = i;
                pix_copy.page_num = i;
                assertEqual(pix_copy.data, pix_original.data);
            end
        end

        %
        %         function test_changes_to_copy_have_no_effect_on_original_no_advance(obj)
        %             data = zeros(9, 30);
        %             npix_in_page = 11;
        %             pix_original = obj.get_pix_with_fake_faccess(data, npix_in_page);
        %             pix_original.signal = 1;
        %
        %             pix_copy = copy(pix_original);
        %             pix_copy.move_to_first_page();
        %             pix_copy.signal = 2;
        %
        %             assertEqual(pix_original.signal, ones(1, numel(pix_original.signal)));
        %             assertEqual(pix_copy.signal, 2*ones(1, numel(pix_copy.signal)));
        %         end

        function test_changes_to_original_before_copy_are_reflected_in_copies(obj)
            skipTest('Re #928 concept of fake_faccess needs clarification')
            data = zeros(9, 30);
            npix_in_page = 11;
            pix_original = obj.get_pix_with_fake_faccess(data, npix_in_page);
            pix_original.signal = 1;
            pix_original.dump_all_pixels_();

            pix_copy = copy(pix_original);
            pix_copy.move_to_first_page();

            assertEqual(pix_copy.signal, ones(1, numel(pix_copy.signal)));
        end

        %         function test_changes_to_original_kept_in_copy_after_advance(obj)
        %             pix_original = PixelDataFileBacked(obj.tst_sqw_file_full_path, 1e2);
        %             pix_original.signal = 1;
        %
        %             pix_copy = copy(pix_original);
        %             pix_copy.advance();
        %
        %             pix_copy.move_to_first_page();
        %             assertEqual(pix_copy.signal, ones(1, numel(pix_copy.signal)));
        %         end

        function test_change_to_original_after_copy_does_not_affect_copy(obj)
            skipTest('Re #928 concept of fake_faccess needs clarification')
            data = zeros(9, 30);
            npix_in_page = 11;
            pix_original = obj.get_pix_with_fake_faccess(data, npix_in_page);
            pix_copy = copy(pix_original);

            pix_copy.signal = 1;
            pix_copy.dump_all_pixels_();

            pix_original.signal = 2;
            pix_original.dump_all_pixels_();

            pix_copy.move_to_first_page();
            assertEqual(pix_copy.signal, ones(1, numel(pix_copy.signal)));
        end

        function test_page_written_correctly_when_page_size_gt_mem_chunk_size(obj)
            skipTest('Re #928 concept of fake_faccess needs clarification')
            warning('off', 'HOR_CONFIG:set_mem_chunk_size');
            hc = hor_config;
            old_config = hc.get_data_to_store();
            npix_to_write = 28;
            size_of_float = 4;
            hc.mem_chunk_size = npix_to_write;

            function clean_up_func(conf_to_restore)
                set(hor_config, conf_to_restore);
                warning('on', 'HOR_CONFIG:set_mem_chunk_size');
            end

            clean_up = onCleanup(@() clean_up_func(old_config));

            npix_in_page = 90;
            data = zeros(obj.NUM_COLS_IN_PIX_BLOCK, npix_in_page + 10);
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);

            pix.data = ones(obj.NUM_COLS_IN_PIX_BLOCK, npix_in_page);
            pix.dump_all_pixels_();

            pix.move_to_page(1);
            assertEqual(pix.data, ones(obj.NUM_COLS_IN_PIX_BLOCK, npix_in_page));
        end

        function test_pixels_read_correctly_if_final_pg_has_1_pixel(obj)
            data = rand(9, 13);
            npix_in_page = 3;

            warning('off', 'HOR_CONFIG:set_mem_chunk_size');
            clobW = onCleanup(@() warning('on', 'HOR_CONFIG:set_mem_chunk_size'));
            hc = hor_config;
            mch_sz = hc.mem_chunk_size;
            hc.mem_chunk_size = npix_in_page;
            clob = onCleanup(@()set(hc, 'mem_chunk_size', mch_sz));

            pix = obj.get_pix_with_fake_faccess(data);

            for i = 1:pix.num_pages
                pix.page_num = i;
                pix_idx_start = (i-1)*npix_in_page+1;
                pix_idx_end = min(pix_idx_start + npix_in_page - 1, pix.num_pixels);
                assertElementsAlmostEqual(pix.data, ...
                                          data(:, pix_idx_start:pix_idx_end), ...
                                          'relative',obj.tol);

            end
        end

%         function test_you_can_append_to_partially_full_PixelData_page(obj)
%             skipTest('Re #928 This is questionable test for allow pixel modification in-place')
%
%             npix_in_page = 11;
%             nexisting_pix = 5;
%             existing_data = rand(9, nexisting_pix);
%             pix = PixelDataFileBacked(existing_data, npix_in_page);
%             minmax = obj.get_ref_range(existing_data);
%             assertEqual(pix.pix_range,minmax);
%
%             data = ones(obj.NUM_COLS_IN_PIX_BLOCK, npix_in_page);
%             pix_to_append = PixelDataFileBacked(data);
%             assertEqual(pix_to_append.pix_range,ones(2,4));
%             minmax(2,:) = ones(1,4);
%
%             pg_offset = npix_in_page - nexisting_pix;
%             expected_pg_1_data = horzcat(existing_data, data(:, 1:pg_offset));
%             expected_pg_2_data = data(:, (pg_offset + 1):end);
%
%             pix.append(pix_to_append);
%             assertEqual(pix.pix_range,minmax, '', obj.tol);
%
%             pix.move_to_first_page();
%             assertEqual(pix.data, expected_pg_1_data, '', obj.tol);
%
%             pix.advance();
%             assertEqual(pix.data, expected_pg_2_data, '', obj.tol);
%             assertEqual(pix.pix_range,minmax, '', obj.tol);
%         end

        function test_error_if_append_called(~)
            pix = PixelDataFileBacked(rand(9, 1));
            f = @() pix.append(rand(9, 1));
            assertExceptionThrown(f, 'HORACE:PixelDataFileBacked:not_implemented');
        end

%         function test_append_does_not_edit_calling_instance_if_nargout_eq_1(obj)
%             skipTest('Re #928 concept of fake_faccess needs clarification')
%             data = rand(9, 30);
%             npix_in_page = 11;
%             [pix,pix_range] = obj.get_pix_with_fake_faccess(data, npix_in_page);
%             pix_to_append = PixelDataFileBacked(rand(9, 5));
%
%             [~] = pix.append(pix_to_append);
%             assertElementsAlmostEqual(pix.pix_range,pix_range,'relative',obj.tol);
%
%             assertEqual(pix.num_pixels, size(data, 2));
%             pix_data = pix.get_all_prop('all');
%             assertElementsAlmostEqual(pix_data, data,'relative',obj.tol);
%         end

%         function test_append_returns_edited_pix_if_nargout_eq_1(obj)
%             skipTest('Re #928 test for filebased pix_range. Has a problem')
%             pix = PixelDataFileBacked(obj.tst_sqw_file_full_path);
%             range1 = pix.pix_range;
%             npix_to_append = 5;
%             pix_to_append = PixelDataFileBacked(rand(9, npix_to_append));
%             range2 =  pix_to_append.pix_range;
%             ref_range = [min(range1(1,:),range2(1,:));...
%                 max(range1(2,:),range2(2,:))];
%             out_pix = pix.append(pix_to_append);
%             % img_db_range, stored in the file is different from
%             % pix(min/max)
%             assertEqual(ref_range,out_pix.pix_range);
%
%             assertEqual(out_pix.num_pixels, pix.num_pixels + pix_to_append.num_pixels);
%             original_pix_data = concatenate_pixel_pages(pix);
%             out_pix_data = concatenate_pixel_pages(out_pix);
%             assertEqual(out_pix_data, horzcat(original_pix_data, pix_to_append.data));
%         end

%         function test_calling_append_with_empty_pixel_data_does_nothing(~)
%             skipTest('Re #928 concept of fake_faccess needs clarification')
%             pix = PixelDataFileBacked(rand(9, 5));
%             range = pix.pix_range;
%             pix_to_append = PixelDataFileBacked();
%             appended_pix = pix.append(pix_to_append);
%             assertEqual(appended_pix.data, pix.data);
%             assertEqual(range,pix.pix_range);
%         end

%         function test_copied_pix_that_has_been_appended_to_has_correct_num_pix(obj)
%             skipTest('Re #928 concept of fake_faccess needs clarification')
%             data = rand(9, 30);
%             pix = PixelDataFileBacked(data);
%             range1 = pix.pix_range;
%             num_appended_pix = 5;
%             pix_to_append = PixelDataFileBacked(rand(9, num_appended_pix));
%             range2 = pix_to_append.pix_range;
%             ref_range = [ ...
%                 min(range1(1,:),range2(1,:));...
%                 max(range1(2,:),range2(2,:)) ...
%                 ];
%
%             pix.append(pix_to_append);
%             assertEqual(ref_range,pix.pix_range, '', obj.tol);
%
%
%             pix_copy = copy(pix);
%             assertEqual(pix.num_pixels, size(data, 2) + num_appended_pix);
%             assertEqual(pix_copy.num_pixels, size(data, 2) + num_appended_pix);
%             assertEqualToTol(ref_range,pix_copy.pix_range, 'reltol', obj.tol);
%         end

        %         function test_has_more_is_true_after_appending_page_to_non_file_backed(obj)
        %             num_pix = 10;
        %             pix = PixelDataMemory(rand(9, 10));
        %             range1 = pix.pix_range;
        %
        %             pix_to_append = PixelDataMemory(rand(9, 5));
        %             range2 = pix_to_append.pix_range;
        %             ref_range = [min(range1(1,:),range2(1,:));...
        %                 max(range1(2,:),range2(2,:))];
        %
        %             pix.append(pix_to_append);
        %             assertEqual(ref_range,pix.pix_range, '', obj.tol);
        %
        %             pix.move_to_first_page();
        %             assertTrue(pix.has_more());
        %             pix.advance();
        %             assertFalse(pix.has_more());
        %             assertEqual(ref_range,pix.pix_range, '', obj.tol);
        %         end


        function test_move_to_page_loads_given_page_into_memory(obj)
            skipTest('Re #928 need better npix force for testing')
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);

            npix_in_page = 9;
            [pix,pix_range] = obj.get_pix_with_fake_faccess(data, npix_in_page);

            for pg_num = [2, 4, 3, 1]
                pg_idx_start = (pg_num - 1)*npix_in_page + 1;
                pg_idx_end = min(pg_num*npix_in_page, num_pix);

                pix.move_to_page(pg_num);
                assertElementsAlmostEqual(pix.data,...
                    data(:, pg_idx_start:pg_idx_end),'relative',obj.tol);
            end
            assertElementsAlmostEqual(pix.pix_range,pix_range,'relative',obj.tol);
        end

        function test_move_to_page_throws_if_arg_exceeds_number_of_pages(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);

            pix = obj.get_pix_with_fake_faccess(data);

            f = @() pix.move_to_page(2);
            assertExceptionThrown(f, 'PIXELDATA:move_to_page');
        end

        function test_move_to_page_throws_if_arg_less_than_1(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);

            pix = obj.get_pix_with_fake_faccess(data);

            f = @() pix.move_to_page(0);
            assertExceptionThrown(f, 'MATLAB:expectedPositive');

            f = @() pix.move_to_page(-1);
            assertExceptionThrown(f, 'MATLAB:expectedPositive');
        end

        function test_move_to_page_throws_if_arg_is_non_scalar(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);

            pix = obj.get_pix_with_fake_faccess(data);

            f = @() pix.move_to_page([1, 2]);
            assertExceptionThrown(f, 'MATLAB:expectedScalar');
        end

        function test_move_to_page_throws_if_arg_is_not_an_int(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);

            pix = obj.get_pix_with_fake_faccess(data);

            f = @() pix.move_to_page(1.5);
            assertExceptionThrown(f, 'MATLAB:expectedInteger');
        end


        function test_get_pixels_retrieves_data_at_absolute_index(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);

            pix = obj.get_pix_with_fake_faccess(data);

            start_idx = 9;
            end_idx = 23;

            pix_chunk = pix.get_pixels(start_idx:end_idx);
            ref_range = obj.get_ref_range(data(:,start_idx:end_idx));
            assertElementsAlmostEqual(pix_chunk.pix_range,ref_range,'relative',obj.tol);
            assertElementsAlmostEqual(pix_chunk.data, ...
                data(:, start_idx:end_idx),'relative',obj.tol);
        end

        function test_get_pixels_retrieves_correct_data_at_page_boundary(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);

            pix = obj.get_pix_with_fake_faccess(data);
            pix_chunk1 = pix.get_pixels(1:3);
            ref_range = obj.get_ref_range(data(:, 1:3));

            assertElementsAlmostEqual(pix_chunk1.data, data(:, 1:3),... ...
                'relative',obj.tol);
            assertElementsAlmostEqual(pix_chunk1.pix_range,ref_range,...
                'relative',obj.tol);


            pix_chunk2 = pix.get_pixels(20);
            ref_range = obj.get_ref_range(data(:, 20));

            assertElementsAlmostEqual(pix_chunk2.data, data(:, 20),...
                'relative',obj.tol);
            assertElementsAlmostEqual(pix_chunk2.pix_range,ref_range,...
                'relative',obj.tol);

            pix_chunk3 = pix.get_pixels(1:1);
            ref_range = obj.get_ref_range(data(:, 1));
            assertElementsAlmostEqual(pix_chunk3.data, data(:, 1),...
                'relative',obj.tol);
            assertElementsAlmostEqual(pix_chunk3.pix_range,ref_range,...
                'relative',obj.tol);
        end

        function test_get_pixels_gets_all_data_if_full_range_requested(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);

            pix = obj.get_pix_with_fake_faccess(data);
            ref_range = obj.get_ref_range(data(:,1:num_pix));
            pix_chunk = pix.get_pixels(1:num_pix);
            assertElementsAlmostEqual(pix_chunk.pix_range,ref_range,...
                'relative',obj.tol);

            assertElementsAlmostEqual(pix_chunk.data,...
                concatenate_pixel_pages(pix),'relative',obj.tol);
        end

        function test_get_pixels_reorders_output_according_to_indices(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            [pix,ref_range] = obj.get_pix_with_fake_faccess(data);

            rand_order = randperm(num_pix);
            shuffled_pix = data(:, rand_order);
            pix_out = pix.get_pixels(rand_order);

            assertElementsAlmostEqual(pix_out.data, shuffled_pix,'relative',obj.tol);
            assertElementsAlmostEqual(pix_out.pix_range,ref_range,'relative',obj.tol);
        end

        function test_get_pixels_throws_invalid_arg_if_indices_not_vector(~)
            pix = PixelDataBase.create();
            f = @() pix.get_pixels(ones(2, 2));
            assertExceptionThrown(f, 'HORACE:PixelDataBase:invalid_argument');
        end

        function test_get_pixels_throws_if_range_out_of_bounds(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            pix = obj.get_pix_with_fake_faccess(data);

            idx_array = 25:35;
            f = @() pix.get_pixels(idx_array);
            assertExceptionThrown(f, 'HORACE:PixelDataBase:invalid_argument');
        end

        function test_get_pixels_throws_if_an_idx_lt_1_with_paged_pix(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            pix = obj.get_pix_with_fake_faccess(data);

            idx_array = -1:20;
            f = @() pix.get_pixels(idx_array);
            assertExceptionThrown(f, 'HORACE:PixelDataBase:invalid_argument');
        end

        function test_get_pixels_throws_if_an_idx_lt_1_with_in_memory_pix(~)
            in_mem_pix = PixelDataMemory(5);
            f = @() in_mem_pix.get_pixels(-1:3);
            assertExceptionThrown(f, 'HORACE:PixelDataBase:invalid_argument');
        end

        function test_get_pixels_throws_if_indices_not_positive_int(~)
            pix = PixelDataBase.create();
            idx_array = 1:0.1:5;
            f = @() pix.get_pixels(idx_array);
            assertExceptionThrown(f, 'HORACE:PixelDataBase:invalid_argument');
        end

        function test_paged_pix_get_pixels_can_be_called_with_a_logical(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            pix = obj.get_pix_with_fake_faccess(data);

            logical_array = logical(randi([0, 1], [1, 10]));
            ref_range = obj.get_ref_range(data(:,logical_array));
            pix_out = pix.get_pixels(logical_array);

            assertElementsAlmostEqual(pix_out.data, data(:, logical_array),...
                'relative',obj.tol);
            assertElementsAlmostEqual(pix_out.pix_range,ref_range,...
                'relative',obj.tol);
        end

        function test_get_pixels_throws_if_logical_1_index_out_of_range(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            pix = obj.get_pix_with_fake_faccess(data);

            logical_array = cat(2, logical(randi([0, 1], [1, num_pix])), true);
            f = @() pix.get_pixels(logical_array);

            assertExceptionThrown(f, 'HORACE:PixelDataBase:invalid_argument');
        end

        function test_get_pixels_ignores_out_of_range_logical_0_indices(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            pix = obj.get_pix_with_fake_faccess(data);

            logical_array = cat(2, logical(randi([0, 1], [1, num_pix])), false);
            pix_out = pix.get_pixels(logical_array);

            assertElementsAlmostEqual(pix_out.data, data(:, logical_array),...
                'relative',obj.tol);
            ref_range = obj.get_ref_range(data(:, logical_array));
            assertElementsAlmostEqual(pix_out.pix_range,ref_range,...
                'relative',obj.tol);
        end

        function test_in_mem_pix_get_pixels_can_be_called_with_a_logical(obj)
            num_pix = 30;
            in_data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            pix = PixelDataMemory(in_data);

            logical_array = logical(randi([0, 1], [1, 10]));
            pix_out = pix.get_pixels(logical_array);

            assertElementsAlmostEqual(pix_out.data, pix.data(:, logical_array),...
                'relative',obj.tol);
            ref_range = obj.get_ref_range(in_data(:,logical_array));
            assertElementsAlmostEqual(pix_out.pix_range,ref_range,...
                'relative',obj.tol);
        end

        function test_get_pixels_can_handle_repeated_indices(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            pix = obj.get_pix_with_fake_faccess(data);

            idx_array = cat(2, randperm(num_pix), randperm(num_pix));

            pix_chunk = pix.get_pixels(idx_array);
            assertElementsAlmostEqual(pix_chunk.data, data(:, idx_array),...
                'relative',obj.tol);
            ref_range = obj.get_ref_range(data(:,idx_array));
            assertElementsAlmostEqual(ref_range,pix_chunk.pix_range,...
                'relative',obj.tol);
        end

        function test_get_pixels_on_file_backed_can_handle_random_indices(obj)
            pix = PixelDataFileBacked(obj.tst_sqw_file_full_path);
            num_pix = pix.num_pixels;
            data = concatenate_pixel_pages(pix);

            idx_array =randperm(num_pix);

            pix_chunk = pix.get_pixels(idx_array);
            assertEqual(pix_chunk.data, data(:, idx_array));
        end

%         function test_pg_size_reports_size_of_partially_filled_pg_after_advance(obj)
%             num_pix = 30;
%             data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
%             pix = obj.get_pix_with_fake_faccess(data);
%
%             assertEqual(pix.page_size, npix_in_page);
%
%             pix.advance();
%             assertEqual(pix.page_size, npix_in_page);
%
%             pix.advance();
%             num_pix_in_final_pg = 8;
%             assertEqual(pix.page_size, num_pix_in_final_pg);
%         end

        function test_get_fields_returns_data_across_pages_by_absolute_index(obj)
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 30);
            pix = obj.get_pix_with_fake_faccess(data);

            indices = [9:13, 20:24];
            sig_var = pix.get_fields({'signal', 'variance'}, indices);
            expected_sig_var = data([obj.SIGNAL_IDX, obj.VARIANCE_IDX], indices);

            assertElementsAlmostEqual(sig_var, expected_sig_var,...
                'relative',obj.tol);
        end

        function test_get_fields_retrieves_correct_data_at_page_boundary(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);

            pix = obj.get_pix_with_fake_faccess(data);

            sig = pix.get_fields('signal', 1:3);
            assertElementsAlmostEqual(sig, data(obj.SIGNAL_IDX, 1:3),...
                'relative',obj.tol);

            sig2 = pix.get_fields('signal', 20);
            assertElementsAlmostEqual(sig2, data(obj.SIGNAL_IDX, 20),...
                'relative',obj.tol);

            sig3 = pix.get_fields('signal', 1:1);
            assertElementsAlmostEqual(sig3, data(obj.SIGNAL_IDX, 1),...
                'relative',obj.tol);
        end

        function test_paged_pix_get_fields_returns_full_data_range_if_no_idx_arg(obj)
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 30);
            pix = obj.get_pix_with_fake_faccess(data);

            var_sig = pix.get_fields({'variance', 'signal'});
            expected_var_sig = data([obj.VARIANCE_IDX, obj.SIGNAL_IDX], :);

            assertElementsAlmostEqual(var_sig, expected_var_sig,...
                'relative',obj.tol);
        end

        function test_paged_pix_get_fields_can_be_called_with_a_logical(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            pix = obj.get_pix_with_fake_faccess(data);

            logical_array = logical(randi([0, 1], [1, 10]));
            sig_var = pix.get_fields({'signal', 'variance'}, logical_array);

            expected_sig_var = data([obj.SIGNAL_IDX, obj.VARIANCE_IDX], ...
                logical_array);
            assertElementsAlmostEqual(sig_var, expected_sig_var,...
                'relative',obj.tol);
        end

        function test_get_fields_throws_if_logical_1_index_out_of_range(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            pix = obj.get_pix_with_fake_faccess(data);

            logical_array = cat(2, logical(randi([0, 1], [1, num_pix])), true);
            f = @() pix.get_fields('signal', logical_array);

            assertExceptionThrown(f, 'HORACE:PixelDataBase:invalid_argument');
        end

        function test_get_fields_ignores_out_of_range_logical_0_indices(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            pix = obj.get_pix_with_fake_faccess(data);

            logical_array = cat(2, logical(randi([0, 1], [1, num_pix])), false);
            var_sig = pix.get_fields({'variance', 'signal'}, logical_array);

            assertElementsAlmostEqual(var_sig, ...
                data([obj.VARIANCE_IDX, obj.SIGNAL_IDX], logical_array),...
                'relative',obj.tol);
        end


        function test_in_mem_pix_get_fields_can_be_called_with_a_logical(obj)
            num_pix = 30;
            pix = PixelDataBase.create(rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix));

            logical_array = logical(randi([0, 1], [1, 10]));
            sig_var = pix.get_fields({'signal', 'variance'}, logical_array);

            assertEqual(sig_var, ...
                pix.data([obj.SIGNAL_IDX, obj.VARIANCE_IDX], logical_array));
        end

        function test_get_fields_can_handle_repeated_indices(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            pix = obj.get_pix_with_fake_faccess(data);

            idx_array = [10 1 10 10 10];

            sig_run = pix.get_fields({'signal', 'run_idx'}, idx_array);
            assertElementsAlmostEqual(sig_run, data([obj.SIGNAL_IDX, obj.RUN_IDX], idx_array),...
                'relative',obj.tol);
        end


        function test_get_fields_reorders_output_according_to_indices(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            [pix, pix_range] = obj.get_pix_with_fake_faccess(data);

            rand_order = randperm(num_pix);
            shuffled_pix = data(:, rand_order);
            sig_var = pix.get_fields({'signal', 'variance'}, rand_order);

            assertElementsAlmostEqual(sig_var, ...
                shuffled_pix([obj.SIGNAL_IDX, obj.VARIANCE_IDX], :),...
                'relative',obj.tol);
            assertElementsAlmostEqual(pix.pix_range,pix_range,...
                'relative',obj.tol);
        end

        function test_get_fields_throws_invalid_arg_if_indices_not_vector(~)
            pix = PixelDataBase.create();
            f = @() pix.get_fields('signal', ones(2, 2));
            assertExceptionThrown(f, 'MATLAB:InputParser:ArgumentFailedValidation');
        end

        function test_get_fields_throws_if_range_out_of_bounds(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            pix = obj.get_pix_with_fake_faccess(data);

            idx_array = 25:35;
            f = @() pix.get_fields('signal', idx_array);
            assertExceptionThrown(f, 'PIXELDATA:get_data');
        end

        function test_get_fields_throws_if_an_idx_lt_1_with_paged_pix(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            pix = obj.get_pix_with_fake_faccess(data);

            idx_array = -1:20;
            f = @() pix.get_fields('signal', idx_array);
            assertExceptionThrown(f, 'MATLAB:InputParser:ArgumentFailedValidation');
        end

        function test_get_fields_throws_if_an_idx_lt_1_with_in_memory_pix(~)
            in_mem_pix = PixelDataMemory(5);
            f = @() in_mem_pix.get_fields('signal', -1:3);
            assertExceptionThrown(f, 'MATLAB:InputParser:ArgumentFailedValidation');
        end

        function test_get_fields_throws_if_indices_not_positive_int(~)
            pix = PixelDataBase.create();
            idx_array = 1:0.1:5;
            f = @() pix.get_fields('signal', idx_array);
            assertExceptionThrown(f, 'MATLAB:InputParser:ArgumentFailedValidation');
        end

        function test_set_data_sets_fields_with_given_values(~)
            pix = PixelDataMemory(30);
            new_data = ones(3, 7);
            fields = {'run_idx', 'signal', 'variance'};
            idxs = [4, 3, 9, 24, 29, 10, 11];
            pix = pix.set_fields(new_data,fields, idxs);

            assertEqual(pix.get_fields(fields, idxs), new_data);

            % Check other fields/indices unchanged
            non_edited_idxs = 1:pix.num_pixels;
            non_edited_idxs(idxs) = [];
            assertEqual(pix.data(:, non_edited_idxs), zeros(9, 23));
        end

        function test_set_data_sets_single_fields_with_given_values(~)
            pix = PixelDataMemory(30);
            new_data = ones(1, 7);
            field = 'run_idx';
            idxs = [4, 3, 9, 24, 29, 10, 11];
            pix = pix.set_fields(new_data,field, idxs);

            assertEqual(pix.get_fields(field, idxs), new_data);

            % Check other fields/indices unchanged
            non_edited_idxs = 1:pix.num_pixels;
            non_edited_idxs(idxs) = [];
            assertEqual(pix.data(:, non_edited_idxs), zeros(9, 23));
        end

        function test_set_data_sets_fields_with_given_values_pix_filebacked(obj)
            num_pix = 30;
            data = zeros(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_per_page = 11;
            pix = obj.get_pix_with_fake_faccess(data);

            new_data = ones(3, 7);
            fields = {'run_idx', 'signal', 'variance'};
            idxs = [4, 3, 9, 24, 29, 10, 11];
            pix.set_fields(new_data,fields,idxs);

            assertEqual(pix.get_fields(fields, idxs), new_data);

            % Check other fields/indices unchanged
            non_edited_idxs = 1:pix.num_pixels;
            non_edited_idxs(idxs) = [];
            unedited_pix = pix.get_pixels(non_edited_idxs);
            assertEqual(unedited_pix.data, zeros(9, 23));
        end

        function test_set_data_errors_if_data_nrows_ne_to_num_fields(~)
            pix = PixelDataMemory(30);
            fields = {'run_idx', 'signal', 'variance'};
            new_data = ones(numel(fields) + 1, 7);
            idxs = [4, 3, 9, 24, 29, 10, 11];
            f = @() pix.set_fields(new_data,fields,  idxs);
            assertExceptionThrown(f, 'HORACE:PixelDataBase:invalid_argument');
        end

        function test_set_data_errors_if_data_ncols_ne_to_num_indices(~)
            pix = PixelDataMemory(30);
            fields = {'run_idx', 'signal', 'variance'};
            idxs = [4, 3, 9, 24, 29, 10, 11];
            new_data = ones(numel(fields), numel(idxs) - 1);
            f = @() pix.set_fields(new_data,fields, idxs);
            assertExceptionThrown(f, 'HORACE:PixelDataBase:invalid_argument');
        end

        function test_set_data_sets_fields_with_given_values_with_logical_idxs(~)
            pix = PixelDataMemory(30);
            new_data = ones(3, 7);
            fields = {'run_idx', 'signal', 'variance'};
            idxs = [4, 3, 9, 24, 29, 10, 11];
            logical_idxs = zeros(1, 30, 'logical');
            logical_idxs(idxs) = true;
            pix = pix.set_fields(new_data,fields,  logical_idxs);

            assertEqual(pix.get_fields(fields, idxs), new_data);

            % Check other fields/indices unchanged
            non_edited_idxs = 1:pix.num_pixels;
            non_edited_idxs(idxs) = [];
            assertEqual(pix.data(:, non_edited_idxs), zeros(9, 23));
        end

        function test_set_data_sets_all_if_abs_pix_indices_not_given(~)
            num_pix = 30;
            pix = PixelDataBase.create(num_pix);
            new_data = ones(3, num_pix);
            fields = {'run_idx', 'signal', 'variance'};
            pix = pix.set_fields(new_data,fields);

            assertEqual(pix.get_fields(fields), new_data);
        end

        % -- Helpers --

        function [pix,pix_range] = get_pix_with_fake_faccess(obj, data, npix)
            pix = PixelDataFileBacked(data);
            pix_range = [min(data(1:4, :), [], 2), ...
                         max(data(1:4, :), [], 2)]';
        end

        function do_pixel_data_loop_with_f(obj, func, data)
            % func should be a function handle, it is evaluated within a
            % while-advance block over some pixel data
            faccess = FakeFAccess(data);

            npix_in_page = 11;
            pix = PixelDataFileBacked(faccess, npix_in_page);

            func(pix, 0);
            for i = 1:pix.num_pages
                pix.page_number = i;
                func(pix, i);
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
