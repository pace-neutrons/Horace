classdef test_PixelData_mask < TestCase

    properties
        BYTES_PER_PIX = 4*PixelDataBase.DEFAULT_NUM_PIX_FIELDS;
        SIGNAL_IDX = 8;
        VARIANCE_IDX = 9;
        ALL_IN_MEM_PG_SIZE = 1e12;
        FLOAT_TOLERANCE = 4.75e-4;
        config_par
    end

    methods

        function obj = test_PixelData_mask(~)
            obj = obj@TestCase('test_PixelData_mask');

        end
        function test_mask_all_ones_memory(obj)
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 11);
            ref_range = obj.get_ref_range(data);
            pix = PixelDataBase.create(data);
            mask_array = ones(1, pix.num_pixels);
            pix_out = pix.mask(mask_array);
            assertEqual(pix_out.data, data);
            assertEqual(pix_out.data_range,ref_range);
        end

        function test_mask_all_zeros_memory(~)
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 11);
            pix = PixelDataMemory(data);
            mask_array = zeros(1, pix.num_pixels);
            pix_out = pix.mask(mask_array);
            assertTrue(isa(pix_out, 'PixelDataBase'));
            assertEqual(pix_out.num_pixels,0);
            assertEqual(pix_out.data_range,PixelDataBase.EMPTY_RANGE);
        end

        function test_mask_raises_if_mask_array_len_neq_to_pg_size_or_num_pixels(obj)
            ws = warning('off','HOR_CONFIG:set_mem_chunk_size');
            clWob = onCleanup(@()warning(ws));

            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 30);
            npix_in_page = 10;
            [pix,~,clOb] = get_pix_with_fake_faccess(data, npix_in_page);

            mask_array = zeros(5);
            f = @() pix.mask(mask_array);
            assertExceptionThrown(f, 'HORACE:PixelDataBase:invalid_argument');
        end

        function test_mask_all_specified_memory(obj)
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 11);
            pix = PixelDataBase.create(data);

            mask_array = ones(1, pix.num_pixels);
            pix_to_remove = [3, 6, 7];
            mask_array(pix_to_remove) = 0;
            ref_ds = data(:,logical(mask_array));
            ref_range = obj.get_ref_range(ref_ds);

            pix = pix.mask(mask_array);

            assertEqual(pix.num_pixels, size(data, 2) - numel(pix_to_remove));
            expected_data = data;
            expected_data(:, pix_to_remove) = [];
            assertEqual(pix.data, expected_data);
            assertEqual(pix.data_range, ref_range);
        end

        function test_mask_fails_in_place(~)
            pix = PixelDataMemory(5);
            function pm=trhower(pix)
                pm = pix.mask(zeros(1, pix.num_pixels), 'logical');
            end
            assertExceptionThrown(@()trhower(pix), 'HORACE:PixelDataBase:invalid_argument');
        end

        function test_mask_npix_filebacked(obj)
            ws = warning('off','HOR_CONFIG:set_mem_chunk_size');
            clWob = onCleanup(@()warning(ws));

            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 20);
            npix_in_page = 11;

            [pix,~,clOb] = get_pix_with_fake_faccess(data, npix_in_page);


            mask_array = [0, 1, 1, 0, 1, 0];
            npix = [4, 5, 1, 2, 3, 5];

            pix = pix.mask(mask_array, npix);

            full_mask_array = repelem(mask_array, npix);
            expected_data = data(:, logical(full_mask_array));
            ref_range = obj.get_ref_range(expected_data);

            actual_data = pix.data(:,1:pix.num_pixels);
            assertElementsAlmostEqual(actual_data, expected_data,'relative',4e-8);
            assertElementsAlmostEqual(pix.data_range, ref_range,'relative',4e-8);
        end

        function test_mask_npix_memory(obj)
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 20);
            pix = PixelDataBase.create(data);

            mask_array = [0, 1, 1, 0, 1, 0];
            npix = [4, 5, 1, 2, 3, 5];

            pix = pix.mask(mask_array, npix);

            full_mask_array = repelem(mask_array, npix);
            expected_data = data(:, logical(full_mask_array));
            ref_range = obj.get_ref_range(expected_data);

            actual_data = pix.get_pixels(1:pix.num_pixels).data;
            assertEqual(actual_data, expected_data);
            assertEqual(pix.data_range, ref_range);

        end

        function test_mask_fail_bad_npix_memory(~)
            pix = PixelDataMemory(5);
            npix = [1, 2];
            f = @() pix.mask([0, 1], npix);
            assertExceptionThrown(f, 'HORACE:PixelDataBase:invalid_argument');
        end

        function test_mask_fail_npix_and_all_specified_memory(~)

            function out = f()
                num_pix = 10;
                pix = PixelDataMemory(rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix));
                mask_array = randi([0, 1], [1, num_pix]);
                npix = rand(1, 4);
                out = pix.mask(mask_array, npix);
            end

            assertExceptionThrown(@() f(), 'HORACE:PixelDataBase:invalid_argument');
        end

        function test_mask_fail_no_args(~)

            function pix = f()
                pix = PixelDataBase.create(rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 10));
                pix = pix.mask();
            end

            assertExceptionThrown(@() f(), 'MATLAB:minrhs');
        end

    end

    methods (Static)
        % -- Helpers --
        function ref_range = get_ref_range(data)
            ref_range = [
                min(data,[],2),...
                max(data,[],2)]';
        end
    end

end
