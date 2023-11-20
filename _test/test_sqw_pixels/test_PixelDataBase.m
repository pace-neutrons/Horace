classdef test_PixelDataBase < TestCase
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
        working_test_file
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

    methods

        function obj = test_PixelDataBase(~)
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
            del_memmapfile_files(obj.tst_sqw_file_full_path);
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
            pix_data_obj.data = data;
            assertEqual(pix_data_obj.num_pixels,1);
            assertEqual(pix_data_obj.coordinates,zeros(4,1));

        end

        function test_PixelData_set_data_all_wrong_size(~)
            pix_data_obj = PixelDataBase.create();
            function thrower(pix,data)
                pix.data = data;
            end
            data = zeros(4,1);
            ME = assertExceptionThrown(@()thrower(pix_data_obj,data), ...
                'HORACE:PixelDataMemory:invalid_argument');
            mess = 'pixel data should be numeric array of ';
            assertTrue(strncmp(ME.message, ...
                mess,numel(mess)))

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

        function test_get_prop_returns_coordinates_for_given_index_range(obj)
            pix_data_obj = obj.get_random_pix_data_(10);
            coords = pix_data_obj.coordinates(:,2:6);
            assertEqual(coords, pix_data_obj.coordinates(:, 2:6));
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
            clOb = set_temporary_config_options(hor_config, 'mem_chunk_size', obj.SMALL_PG_SIZE);

            % the first page is loaded on access, so this first assert which accesses
            % .variance is necessary to set pix.page_size
            assertEqual(size(obj.pix_data_from_file.variance), ...
                [1, obj.pix_data_from_file.page_size]);
            assertEqual(obj.pix_data_from_file.page_size, expected_page_size);
        end

        function test_data_values_are_not_affected_by_changes_in_copies(~)
            n_rows = 5;
            p1 = PixelDataBase.create(ones(9, n_rows));
            p2 = copy(p1);
            p2.u1 = zeros(1, n_rows);
            assertEqual(p2.u1, zeros(1, n_rows));
            assertEqual(p1.u1, ones(1, n_rows));
        end

        function test_loop_to_sum_signal_data(obj)
            data = randi([0, 99], 9, 30);
            npix_in_page = 11;
            [pix, ~, clob] = get_pix_with_fake_faccess(data, npix_in_page);

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

        function test_editing_a_field_changes_page(obj)

            data = rand(9, 10);
            faccess = FakeFAccess(data);
            for i = 1:numel(obj.pix_fields)
                pix = PixelDataBase.create(faccess);
                pix.(obj.pix_fields{i}) = 1;
                assertEqual(pix.page_size, 10);
                nf = pix.get_field_count(obj.pix_fields{i});
                assertEqual(pix.(obj.pix_fields{i}),ones(nf,10))
            end
        end

        function test_set_fields_with_nonscalar_data_sets_Ndata(obj)
            data = zeros(9, 30);
            npix_in_page = 11;
            [pix, ~, clob] = get_pix_with_fake_faccess(data, npix_in_page);

            pix.page_num = 2;
            pix.u1 = ones(1,11);

            % check u1 values are set
            pix.page_num = 1;
            assertEqual(pix.u1, zeros(1, 11));
            pix.page_num = 2;
            assertEqual(pix.u1, ones(1, 11));
            pix.page_num = 3;
            assertEqual(pix.u1, zeros(1, 8));

        end

        function test_num_pixels_is_a_double_if_faccess_returns_uint(~)
            npix = 30;
            data = rand(9, npix);
            faccess = FakeFAccess(data);
            faccess = faccess.set_npixels(uint64(npix));

            pix = PixelDataBase.create(faccess);
            assertTrue(isa(pix.num_pixels, 'double'));
        end

        function test_num_pixels_is_a_double_memory(obj)
            assertTrue(isa(obj.pixel_data_obj.num_pixels, 'double'));
        end

        function test_num_pixels_is_a_double_filebacked(obj)
            assertTrue(isa(obj.pix_data_from_file.num_pixels, 'double'));
        end

        function test_pixels_read_correctly_if_final_pg_has_1_pixel(obj)
            data = rand(9, 13);
            npix_in_page = 3;

            [pix, ~, clob] = get_pix_with_fake_faccess(data, npix_in_page);

            for i = 1:pix.num_pages
                pix.page_num = i;
                pix_idx_start = (i-1)*npix_in_page+1;
                pix_idx_end = min(pix_idx_start + npix_in_page - 1, pix.num_pixels);
                assertElementsAlmostEqual(pix.data, ...
                    data(:, pix_idx_start:pix_idx_end), ...
                    'relative',obj.tol);

            end
        end

        function test_error_if_append_called(~)
            pix = PixelDataFileBacked(rand(9, 1));
            f = @() pix.append(rand(9, 1));
            assertExceptionThrown(f, 'HORACE:PixelDataFileBacked:not_implemented');
        end

        function test_move_to_page_loads_given_page_into_memory(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);

            npix_in_page = 9;
            [pix, ~, clob] = get_pix_with_fake_faccess(data, npix_in_page);

            for pg_num = [2, 4, 3, 1]
                pg_idx_start = (pg_num - 1)*npix_in_page + 1;
                pg_idx_end = min(pg_num*npix_in_page, num_pix);

                pix.page_num = pg_num;
                assertElementsAlmostEqual(pix.data,...
                    data(:, pg_idx_start:pg_idx_end),'relative',obj.tol);
            end
        end

        function test_move_to_page_throws_if_arg_exceeds_number_of_pages(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;

            [pix, ~, clob] = get_pix_with_fake_faccess(data, npix_in_page);
            function set_page(pix,npage)
                pix.page_num = npage;
            end

            f = @()set_page(pix,50);
            assertExceptionThrown(f, 'HORACE:PixelDataFileBacked:invalid_argument');
        end

        function test_move_to_page_throws_if_arg_less_than_1(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;

            [pix, ~, clob] = get_pix_with_fake_faccess(data, npix_in_page);
            function set_page(pix,npage)
                pix.page_num = npage;
            end


            f = @()set_page(pix,0);
            assertExceptionThrown(f, 'HORACE:PixelDataFileBacked:invalid_argument');

            f = @()set_page(pix,-1);
            assertExceptionThrown(f, 'HORACE:PixelDataFileBacked:invalid_argument');
        end

        function test_move_to_page_throws_if_arg_is_non_scalar(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;

            [pix, ~, clob] = get_pix_with_fake_faccess(data, npix_in_page);

            function set_page(pix,npage)
                pix.page_num = npage;
            end

            f = @()set_page(pix,[1, 2]);
            assertExceptionThrown(f, 'HORACE:PixelDataFileBacked:invalid_argument');
        end

        function test_get_pixels_retrieves_data_at_absolute_index(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;

            [pix, ~, clob] = get_pix_with_fake_faccess(data, npix_in_page);

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
            npix_in_page = 10;

            [pix, ~, clob] = get_pix_with_fake_faccess(data, npix_in_page);
            pix_chunk1 = pix.get_pixels(1:3);
            ref_range = obj.get_ref_range(data(:, 1:3));

            assertElementsAlmostEqual(pix_chunk1.data, data(:, 1:3),...
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
            npix_in_page = 11;

            [pix, ~, clob] = get_pix_with_fake_faccess(data, npix_in_page);
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
            npix_in_page = 11;
            [pix, ref_range, clob] = get_pix_with_fake_faccess(data, npix_in_page);

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
            npix_in_page = 11;
            [pix, ~, clob] = get_pix_with_fake_faccess(data, npix_in_page);

            idx_array = 25:35;
            f = @() pix.get_pixels(idx_array);
            assertExceptionThrown(f, 'HORACE:PixelDataBase:invalid_argument');
        end

        function test_get_pixels_throws_if_an_idx_lt_1_with_paged_pix(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            [pix, ~, clob] = get_pix_with_fake_faccess(data, npix_in_page);

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
            npix_in_page = 11;
            [pix, ~, clob] = get_pix_with_fake_faccess(data, npix_in_page);

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
            npix_in_page = 11;
            [pix, ~, clob] = get_pix_with_fake_faccess(data, npix_in_page);

            logical_array = cat(2, logical(randi([0, 1], [1, num_pix])), true);
            f = @() pix.get_pixels(logical_array);

            assertExceptionThrown(f, 'HORACE:PixelDataBase:invalid_argument');
        end

        function test_get_pixels_ignores_out_of_range_logical_0_indices(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            [pix, ~, clob] = get_pix_with_fake_faccess(data, npix_in_page);

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

            assertElementsAlmostEqual(pix_out.data, pix.data(:, [logical_array,false(1,20)]),...
                'relative',obj.tol);
            ref_range = obj.get_ref_range(in_data(:,[logical_array,false(1,20)]));
            assertElementsAlmostEqual(pix_out.pix_range,ref_range,...
                'relative',obj.tol);
        end

        function test_get_pixels_can_handle_repeated_indices(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            [pix, ~, clob] = get_pix_with_fake_faccess(data, npix_in_page);

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

        function test_get_prop_returns_data_across_pages_by_absolute_index(obj)
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 30);
            npix_in_page = 11;
            [pix, ~, clob] = get_pix_with_fake_faccess(data, npix_in_page);

            indices = [9:13, 20:24];
            pix_data = pix.get_pixels(indices,'-raw');
            expected_data = data(:, indices);

            assertElementsAlmostEqual(pix_data , expected_data,...
                'relative',obj.tol);
        end

        function test_get_prop_retrieves_correct_data_at_page_boundary(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 10;

            [pix, ~, clob] = get_pix_with_fake_faccess(data, npix_in_page);

            sig = pix.signal(1:3);
            assertElementsAlmostEqual(sig, data(obj.SIGNAL_IDX, 1:3),...
                'relative',obj.tol);

            sig2 = pix.signal(10);
            assertElementsAlmostEqual(sig2, data(obj.SIGNAL_IDX, 10),...
                'relative',obj.tol);

            sig3 = pix.signal(1:1);
            assertElementsAlmostEqual(sig3, data(obj.SIGNAL_IDX, 1),...
                'relative',obj.tol);
        end

        function test_paged_pix_get_prop_can_be_called_with_a_logical(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            [pix, ~, clob] = get_pix_with_fake_faccess(data, npix_in_page);

            logical_array = logical(randi([0, 1], [1, 10]));
            sig_var = pix.sig_var(:,logical_array);

            expected_sig_var = data([obj.SIGNAL_IDX, obj.VARIANCE_IDX], ...
                logical_array);
            assertElementsAlmostEqual(sig_var, expected_sig_var,...
                'relative',obj.tol);
        end

        function test_get_prop_throws_if_logical_1_index_out_of_range(~)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            [pix, ~, clob] = get_pix_with_fake_faccess(data, npix_in_page);

            logical_array = cat(2, logical(randi([0, 1], [1, num_pix])), true);
            function ss=thrower(pix,lar)
                ss = pix.signal(lar);
            end
            f = @()thrower(pix,logical_array);

            assertExceptionThrown(f, 'MATLAB:badsubscript');
        end
        function test_get_pix_return_partial_pix(obj)

            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            [pix, ~, clob] = get_pix_with_fake_faccess(data, npix_in_page);

            logical_array = logical(randi([0, 1], [1, num_pix]));
            r_data = pix.get_pixels(logical_array,'sig_var','-raw');

            idx = PixelDataBase.field_index('sig_var');
            assertElementsAlmostEqual(r_data, data(idx,logical_array),...
                'relative',obj.tol);
        end


        function test_get_pix_accepts_logical_indices(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            [pix, ~, clob] = get_pix_with_fake_faccess(data, npix_in_page);

            logical_array = logical(randi([0, 1], [1, num_pix]));
            r_data = pix.get_pixels(logical_array,'-raw');

            assertElementsAlmostEqual(r_data, data(:,logical_array),...
                'relative',obj.tol);
        end

        function test_in_mem_pix_get_prop_can_be_called_with_a_logical(obj)
            num_pix = 30;
            pix = PixelDataBase.create(rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix));

            logical_array = logical(randi([0, 1], [1, 10]));
            sig_var = pix.sig_var(:, logical_array);

            assertEqual(sig_var, ...
                pix.data([obj.SIGNAL_IDX, obj.VARIANCE_IDX], logical_array));
        end

        function test_get_prop_can_handle_repeated_indices(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            [pix, ~, clob] = get_pix_with_fake_faccess(data, npix_in_page);

            idx_array = [10 1 10 10 10];
            sig = pix.signal(idx_array);
            rid = pix.run_idx(idx_array);

            assertElementsAlmostEqual([sig;rid], data([obj.SIGNAL_IDX, obj.RUN_IDX], idx_array),...
                'relative',obj.tol);
        end

        function test_pix_range_eq_data_range(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);

            npix_in_page = 11;
            [pix, pix_range, clob] = get_pix_with_fake_faccess(data, npix_in_page);
            assertElementsAlmostEqual(pix.pix_range,pix_range,...
                'relative',obj.tol);
        end

        function test_get_prop_reorders_output_according_to_indices(obj)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            [pix, pix_range, clob] = get_pix_with_fake_faccess(data, npix_in_page);

            rand_order = randperm(num_pix);
            shuffled_pix = data(:, rand_order);
            pix = pix.get_pixels(rand_order,'-raw_data');

            assertElementsAlmostEqual(pix,shuffled_pix,...
                'relative',obj.tol);
        end

        function test_get_prop_throws_if_range_out_of_bounds(~)
            num_pix = 30;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix);
            npix_in_page = 11;
            [pix, ~, clob] = get_pix_with_fake_faccess(data, npix_in_page);

            function ss=thrower(pix,lar)
                ss = pix.signal(lar);
            end

            idx_array = 25:35;
            f = @()thrower(pix,idx_array);
            assertExceptionThrown(f, 'MATLAB:badsubscript');
        end

        function test_set_data_sets_fields_with_given_values(~)
            pix = PixelDataMemory(30);
            new_data = ones(3, 7);

            idxs = [4, 3, 9, 24, 29, 10, 11];
            pix.run_idx(idxs) =  new_data(1,:);
            pix.sig_var(:,idxs) =  new_data(2:3,:);

            idx = pix.run_idx(idxs);
            sv  = pix.sig_var(:,idxs);

            assertEqual([idx;sv], new_data);

            % Check other fields/indices unchanged
            non_edited_idxs = 1:pix.num_pixels;
            non_edited_idxs(idxs) = [];
            assertEqual(pix.data(:, non_edited_idxs), zeros(9, 23));
        end
    end
    %=======================================================================
    % Build operation file name
    methods
        function test_op_filename_cur_source_cur_targ_with_path(~)
            [op_name,to_move] = PixelDataBase.build_op_filename( ...
                fullfile('some_path','some_sqw.sqw'),fullfile('some_path','some_sqw.sqw'));
            assertTrue(to_move)
            [op_fp,op_fn,op_fext] = fileparts(op_name);

            assertEqual(op_fn,'some_sqw');
            assertEqual(op_fp,'some_path');
            assertTrue(strncmp(op_fext,'.tmp_',5));
        end

        function test_op_filename_cur_source_cur_targ(~)
            [op_name,to_move] = PixelDataBase.build_op_filename( ...
                'some_sqw.sqw','some_sqw.sqw');
            assertTrue(to_move)
            [op_fp,op_fn,op_fext] = fileparts(op_name);

            assertEqual(op_fn,'some_sqw');
            assertEqual(op_fp,pwd);
            assertTrue(strncmp(op_fext,'.tmp_',5));
        end

        function test_op_filename_cur_source_other_targ(~)
            [op_name,to_move] = PixelDataBase.build_op_filename( ...
                'some_sqw.sqw','other_sqw.sqw');
            assertFalse(to_move)
            [op_fp,op_fn,op_fext] = fileparts(op_name);

            assertEqual(op_fn,'other_sqw');
            assertTrue(isempty(op_fp));
            assertTrue(strcmp(op_fext,'.sqw'));
        end

        function test_op_filename_undef_source_empty(obj)
            [op_name,to_move] = PixelDataBase.build_op_filename( ...
                'some_sqw.sqw','');
            assertFalse(to_move)
            [op_fp,op_fn,op_fext] = fileparts(op_name);

            hc = hor_config;
            dir = hc.working_directory;
            assertEqual(op_fn,'some_sqw');

            [op_fp,dir] = obj.unify_directories(op_fp,dir);
            assertEqual(op_fp,dir);
            assertTrue(strncmp(op_fext,'.tmp_',5));
        end

        function test_op_filename_empty_empty(obj)
            [op_name,to_move] = PixelDataBase.build_op_filename('','');
            assertFalse(to_move)
            [op_fp,op_fn,op_fext] = fileparts(op_name);

            hc = hor_config;
            dir = hc.working_directory;
            assertEqual(op_fn,'in_mem');
            [op_fp,dir] = obj.unify_directories(op_fp,dir);
            assertEqual(op_fp,dir);
            assertTrue(strncmp(op_fext,'.tmp_',5));
        end
    end
    % -- Helpers --
    methods(Static, Access=private)
        function [dir1,dir2] = unify_directories(dir1,dir2)
            % helper function which would make the folders look similar
            % regardless of the presence of filesep symbol at the end
            if ispc
                eolr_sym = '\$';
            else
                eolr_sym = '$';
            end
            dir1 = regexprep(dir1,[filesep,eolr_sym],'');
            dir2 = regexprep(dir2,[filesep,eolr_sym],'');

        end

        function [pix_data,data_range] = get_random_pix_data_(rows)
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, rows);
            pix_data = PixelDataMemory(data);
            data_range = pix_data.data_range;

        end

        function ref_range = get_ref_range(data)
            ref_range = [min(data(1:4, :),[],2),...
                max(data(1:4, :),[],2)]';
        end
        function do_pixel_data_loop_with_f(obj, func, data)
            % func should be a function handle, it is evaluated within a
            % while-advance block over some pixel data

            npix_in_page = 11;
            [pix, ~, clob] = get_pix_with_fake_faccess(data, npix_in_page);

            func(pix, 0);
            for i = 1:pix.num_pages
                pix.page_number = i;
                func(pix, i);
            end
        end
        function clear_config(obj,hc)
            if ~isempty(obj.initial_mem_chunk_size)
                hc.mem_chunk_size = obj.initial_mem_chunk_size;
            end
        end
    end
end
