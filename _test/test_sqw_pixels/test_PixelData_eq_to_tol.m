classdef test_PixelData_eq_to_tol < TestCase

    properties
        BYTES_PER_PIX = 4*PixelDataBase.DEFAULT_NUM_PIX_FIELDS;
        SIGNAL_IDX = 8;
        VARIANCE_IDX = 9;
        ALL_IN_MEM_PG_SIZE = 1e12;
        FLOAT_TOLERANCE = 4.75e-4;
        config_par
    end

    methods

        function obj = test_PixelData_eq_to_tol (~)
            obj = obj@TestCase('test_PixelData_eq_to_tol');
        end

        %
        function test_equal_to_tol_PixelData_ne_raw_array_memory(~)
            raw_array = zeros(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 10);
            pix = PixelDataBase.create(raw_array);
            [ok, mess] = equal_to_tol(pix, raw_array);
            assertFalse(ok);
            assertTrue(contains(mess, 'PixelData'));
            assertTrue(contains(mess, 'double'));
        end

        function test_equal_to_tol_num_pixels_neq(~)
            data = zeros(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 10);
            pix1 = PixelDataBase.create(data);
            pix2 = PixelDataBase.create(data(:, 1:9));
            assertFalse(equal_to_tol(pix1, pix2));
        end

        function test_equal_to_tol_same_data_memory(~)
            data = ones(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 10);
            pix1 = PixelDataBase.create(data);
            pix2 = PixelDataBase.create(data);
            assertTrue(equal_to_tol(pix1, pix2));
            assertTrue(equal_to_tol(pix2, pix1));
        end

        function test_equal_to_tol_same_data_filebacked(obj)
            ws = warning('off','HOR_CONFIG:set_mem_chunk_size');
            clWob = onCleanup(@()warning(ws));

            data = ones(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 20);
            npix_in_page = 10;
            pix1 = get_pix_with_fake_faccess(data, npix_in_page);
            [pix2,~,clOb] = get_pix_with_fake_faccess(data, npix_in_page);

            assertTrue(equal_to_tol(pix1, pix2));
            assertTrue(equal_to_tol(pix2, pix1));
        end

        function test_equal_to_tol_w_tolerance_filebacked(obj)
            ws = warning('off','HOR_CONFIG:set_mem_chunk_size');
            clWob = onCleanup(@()warning(ws));

            data = ones(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 20);
            npix_in_page = 10;
            tol = 0.1;
            pix1 = get_pix_with_fake_faccess(data, npix_in_page);
            [pix2,~,clOb] = get_pix_with_fake_faccess(data - (tol - 0.01), npix_in_page);

            assertTrue(equal_to_tol(pix1, pix2, tol));
            assertTrue(equal_to_tol(pix2, pix1, tol));
        end

        function test_equal_to_tol_diff_data_filebacked(obj)
            ws = warning('off','HOR_CONFIG:set_mem_chunk_size');
            clWob = onCleanup(@()warning(ws));

            data = ones(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 20);
            data2 = data;
            data2(11) = 0.9;
            npix_in_page = 10;

            pix1 = get_pix_with_fake_faccess(data, npix_in_page);
            [pix2,~,clOb] = get_pix_with_fake_faccess(data2, npix_in_page);
            assertFalse(equal_to_tol(pix1, pix2));
            assertFalse(equal_to_tol(pix2, pix1));
        end

        function test_equal_to_tol_same_data_memory_filebacked(obj)
            ws = warning('off','HOR_CONFIG:set_mem_chunk_size');
            clWob = onCleanup(@()warning(ws));


            data = ones(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 20);
            npix_in_page = 6;

            pix1 = PixelDataBase.create(data);
            [pix2,~,clOb] = get_pix_with_fake_faccess(data, npix_in_page);
            assertTrue(equal_to_tol(pix1, pix2));
            assertTrue(equal_to_tol(pix2, pix1));
        end

        function test_equal_to_tol_diff_data_memory_filebacked(obj)
            ws = warning('off','HOR_CONFIG:set_mem_chunk_size');
            clWob = onCleanup(@()warning(ws));

            data = ones(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 20);
            npix_in_page = 6;

            pix1 = PixelDataBase.create(data);
            [pix2,~,clOb] = get_pix_with_fake_faccess(data-1, npix_in_page);
            assertFalse(equal_to_tol(pix1, pix2));
            assertFalse(equal_to_tol(pix2, pix1));
        end

        function test_equal_to_tol_nan_equal_true_memory(~)
            data = ones(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 20);
            data(:, [5, 10, 15]) = nan;
            pix1 = PixelDataBase.create(data);
            pix2 = PixelDataBase.create(data);

            assertTrue(equal_to_tol(pix1, pix2, 'nan_equal', true));
        end

        function test_equal_to_tol_nan_equal_false_memory(~)
            data = ones(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 20);
            data(:, [5, 10, 15]) = nan;
            pix1 = PixelDataBase.create(data);
            pix2 = PixelDataBase.create(data);

            assertFalse(equal_to_tol(pix1, pix2, 'nan_equal', false));
        end

    end

    methods (Static)
        function ref_range = get_ref_range(data)
            ref_range = [
                min(data,[],2),...
                max(data,[],2)]';
        end
    end

end
