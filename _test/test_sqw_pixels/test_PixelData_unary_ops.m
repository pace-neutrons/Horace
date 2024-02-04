classdef test_PixelData_unary_ops < TestCase

    properties
        BYTES_PER_PIX = 4*PixelDataBase.DEFAULT_NUM_PIX_FIELDS;
        SIGNAL_IDX = 8;
        VARIANCE_IDX = 9;
        ALL_IN_MEM_PG_SIZE = 1e12;
        FLOAT_TOLERANCE = 4.75e-4;
        config_par
    end

    methods

        function obj = test_PixelData_unary_ops(~)
            obj = obj@TestCase('test_PixelData_operations');
        end
        function test_do_unary_op_cosine_filebacked(obj)

            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 50);
            npix_in_page = 11;
            [pix,~,clOb] = get_pix_with_fake_faccess(data, npix_in_page);

            pix = pix.do_unary_op(@cos);
            % Loop back through and validate values

            file_backed_data = pix.get_pixels(1:50,'-raw_data');
            expected_data = data;
            expected_data(obj.SIGNAL_IDX, :) = ...
                cos(expected_data(obj.SIGNAL_IDX, :));

            expected_data(obj.VARIANCE_IDX, :) = ...
                abs(1 - expected_data(obj.SIGNAL_IDX, :).^2) .* ...
                expected_data(obj.VARIANCE_IDX, :);

            assertEqual(file_backed_data, expected_data, '', obj.FLOAT_TOLERANCE);
        end

        function test_do_unary_op_output_not_change_orig(~)
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 10);
            pix = PixelDataBase.create(data);
            sin_pix = pix.do_unary_op(@sin);
            assertEqual(pix.data, data);

            sin_pix_om = pix.sin();
            assertEqual(sin_pix,sin_pix_om);
        end

        function test_tmp_file_redirected(~)

            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 50);
            npix_in_page = 11;

            [pix,~,clOb] = get_pix_with_fake_faccess(data, npix_in_page);


            % Make temp file
            sin_pix = pix.do_unary_op(@sin);
            pg_data = sin_pix.get_pixels('-raw');

            % shallow? Copy
            sin_pix_cpy = PixelDataFileBacked(sin_pix);
            assertEqual(sin_pix.full_filename, sin_pix_cpy.full_filename)

            sin_pix = sin_pix.do_unary_op(@sin);

            assertFalse(equal_to_tol(sin_pix.full_filename, sin_pix_cpy.full_filename))
            assertTrue(is_file(sin_pix.full_filename))
            assertTrue(is_file(sin_pix_cpy.full_filename))
            assertEqualToTol(sin_pix_cpy.data, pg_data)
        end
        function test_unary_op_memory_vs_filebacked_with_op_manager(~)
            unary_ops = {
                @acos, [0, 1], ...
                @acosh, [1, 3], ...
                @acot, [0, 1], ...
                @acoth, [10, 15], ...
                @acsc, [1, 3], ...
                @acsch, [1, 3], ...
                @asec, [1.5, 3], ...
                @asech, [0, 1], ...
                @asin, [0, 1], ...
                @asinh, [1, 3], ...
                @atan, [0, 1], ...
                @atanh, [0, 0.5], ...
                @cos, [0, 1], ...
                @cosh, [0, 1], ...
                @cot, [0.1, 1], ...
                @coth, [1.5, 3], ...
                @csc, [0.5, 2.5], ...
                @csch, [1, 3], ...
                @exp, [0, 1], ...
                @log, [1, 3], ...
                @log10, [1, 3], ...
                @sec, [2, 4], ...
                @sech, [0, 1.4], ...
                @sin, [0, 3], ...
                @sinh, [0, 3], ...
                @sqrt, [0, 3], ...
                @tan, [0, 1], ...
                @tanh, [0, 3], ...
                };

            % allow small pages, and clean-up these setting on completeon
            hc = hor_config;
            conf = hc.get_data_to_store();
            clWOb = set_temporary_warning('off','HOR_CONFIG:set_mem_chunk_size');
            clConfOb = onCleanup(@()set(hc,conf));

            % For each unary operator, perform the operation on some file-backed
            % data and compare the result to the same operation used on the same
            % data all held in memory
            num_pix = 55;
            npix_in_page = 10;
            for i = 1:2:numel(unary_ops)
                unary_op = unary_ops{i};
                data_range = unary_ops{i+1};

                data = get_random_data_in_range( ...
                    PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix, data_range);

                [pix,~,clOb] = get_pix_with_fake_faccess(data, npix_in_page);

                pix = unary_op(pix);
                clear clOb;
                pix_in_mem = PixelDataMemory(single(data));
                pix_in_mem = unary_op(pix_in_mem);

                try
                    assertEqualToTol(pix, pix_in_mem, 'tol',[1e-4, 1e-4]);
                catch ME
                    fprintf('failure at operation N%d, function %s\n', ...
                        i,func2str(unary_op))
                    rethrow(ME)
                end
            end
        end

    end
    %
end
