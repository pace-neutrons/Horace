classdef test_sqw_binary_ops < TestCase
    properties
        SIGNAL_IDX = 8;
        VARIANCE_IDX = 9;
        
        test_sqw_file_path;
        test_sqw_2d_file_path;
        ref_d1d_data = [];

        sqw_in_memory;
        sqw_with_pages;

        call_count_transfer_;

        mem_chunk_size
    end

    methods

        function obj = test_sqw_binary_ops(name)
            if ~exist('name','var')
                name = 'test_sqw_binary_ops';
            end
            obj = obj@TestCase(name);

            pths = horace_paths();
            obj.test_sqw_file_path    = fullfile(pths.test_common, 'sqw_1d_1.sqw');
            obj.test_sqw_2d_file_path = fullfile(pths.test_common, 'sqw_2d_1.sqw');

            % Load a 1D SQW file and recalculate incorrect data-pix ratio,
            % present in reference the files
            w1 = sqw(obj.test_sqw_file_path,'file_backed',true);
            obj.sqw_with_pages = w1.recompute_bin_data();

            w1 = sqw(obj.test_sqw_file_path,'file_backed',false);
            obj.sqw_in_memory  = w1.recompute_bin_data();
            obj.ref_d1d_data   = obj.sqw_in_memory.data;

        end

        function test_add_scalar_memory_with_op_man(obj)
            w1 = obj.sqw_in_memory;

            w1_res1 = w1 + 3;
            w1_res2 = 3 + w1;
            assertEqual(w1_res1 , w1_res2);
        end
        function test_add_scalar_memory(obj)
            w1 = obj.sqw_in_memory;
            operand = 3;
            w_res = w1 + operand;
            assertEqual(w_res.data.s, operand + w1.data.s);
            assertEqual(w_res.pix.signal, operand + w1.pix.signal);
            assertEqual(w_res.pix.data([1:7, 9], :), w1.pix.data([1:7, 9], :));
        end

        function test_add_scalar_filebacked(obj)
            w1 = obj.sqw_with_pages;
            operand = 3;
            clConf = set_temporary_config_options(hor_config,'mem_chunk_size',20000);
            w_res_fb = w1 + operand;

            w_res_mb = operand + obj.sqw_in_memory;
            assertEqualToTol(w_res_mb,w_res_fb,'tol',[4*eps('single'),1.e-4])

        end
        function test_minus_scalar_flip_memory_with_opman(obj)
            w1 = obj.sqw_in_memory;
            operand = 3;
            w_res = operand - w1;

            assertEqualToTol(w_res.data.s, operand - w1.data.s);
            assertEqual(w_res.pix.signal, operand - w1.pix.signal);
            assertEqual(w_res.pix.data([1:7, 9], :), w1.pix.data([1:7, 9], :));
        end

        function test_minus_scalar_flip_with_file(obj)
            w1 = obj.sqw_with_pages;
            old_pix_data = concatenate_pixel_pages(w1.pix);

            operand = 30000;
            clConf = set_temporary_config_options(hor_config,'mem_chunk_size',20000);

            w_res = operand - w1;
            new_pix_data = concatenate_pixel_pages(w_res.pix);

            assertElementsAlmostEqual(new_pix_data(8,:), ...
                operand - old_pix_data(8,:),'relative',4*eps('single'));
            assertElementsAlmostEqual(old_pix_data([1:7, 9], :), ...
                new_pix_data([1:7, 9], :),'relative',4*eps('single'));
            assertElementsAlmostEqual(w_res.data.s,operand-w1.data.s, ...
                'relative',7e-4);
        end

        function test_mtimes_scalar_filebacked_with_opman(obj)
            w1 = obj.sqw_with_pages;
            operand = 1.5;
            clConf = set_temporary_config_options(hor_config,'mem_chunk_size',20000);

            w_res = operand*w1;
            new_pix_data = concatenate_pixel_pages(w_res.pix);

            assertElementsAlmostEqual(new_pix_data(8, :), ...
                obj.sqw_in_memory.pix.signal*operand, ...
                'relative', 4*eps('single'));
            assertElementsAlmostEqual(new_pix_data(9, :), ...
                (operand.^2).*obj.sqw_in_memory.pix.variance, ...
                'relative',  4*eps('single'));
            assertElementsAlmostEqual(w_res.data.s, ...
                obj.sqw_in_memory.data.s.*operand,'relative',1.e-5);
        end

        function test_mrdivide_scalar_flip_memory_with_opman(obj)
            w1 = obj.sqw_in_memory;
            operand = 1.5;

            w_res = operand/w1;

            assertEqual(w_res.pix.signal, operand./w1.pix.signal);
            expected_var = w1.pix.variance.*((w_res.pix.signal./w1.pix.signal).^2);
            assertEqual(w_res.pix.variance, expected_var);

            ws = recompute_bin_data(w_res);
            assertEqualToTol(ws.data,w_res.data);
        end

        %------------------------------------------------------------------

        function test_add_PixelData_neq_num_pixels_memory(obj)
            lop = sqw(obj.test_sqw_2d_file_path);
            f = @()plus(obj.sqw_in_memory,lop);
            assertExceptionThrown(f, 'HERBERT:data_op_interface:invalid_argument');
        end


        function test_minus_PixelData_filebacked_memory_one_stroke(obj)
            w1 = obj.sqw_with_pages;
            w2 = obj.sqw_in_memory;
            clOb = set_temporary_config_options(hor_config, ...
                'mem_chunk_size',floor(w1.num_pixels/3));

            w_diff = w1 - w2;

            assertElementsAlmostEqual(w_diff.data.s,zeros(size(w_diff.data.s)));
        end

        function test_c_eq_a_plus_b_with_opman(obj)
            w1 = obj.sqw_with_pages;
            w2 = obj.sqw_with_pages;
            % five filebacked operations! use apply
            w3 = w1.cos()^2 + w2.sin()^2;

            assertTrue(is_file(w1.full_filename));
            assertTrue(is_file(w2.full_filename));
            assertTrue(is_file(w3.full_filename));

            assertElementsAlmostEqual(w3.data.s,ones(size(w3.data.s)));
            new_pix_data = concatenate_pixel_pages(w3.pix);
            assertEqualToTol(new_pix_data(8,:),single(ones(1, w3.num_pixels)) ...
                ,'tol',4*eps('single'));
        end

        function test_add_1d_dnd_filebacked(obj)
            dnd_obj = obj.ref_d1d_data;
            wf = obj.sqw_with_pages;

            obj.check_with_1d_dnd_returns_correct_pix_filebacked(wf,dnd_obj)
        end

    end

    % Check methods called in tests
    methods
        function check_with_1d_dnd_returns_correct_pix_filebacked(obj,ws,dnd_obj)
            npix = ws.data.npix;

            assertTrue(ws.pix.is_filebacked);
            w_res = dnd_obj + ws;

            original_pix_data = concatenate_pixel_pages(ws.pix);
            new_pix_data = concatenate_pixel_pages(w_res.pix);

            expected_pix = original_pix_data;
            expected_pix(obj.SIGNAL_IDX, :) = ...
                expected_pix(obj.SIGNAL_IDX, :) + repelem(dnd_obj.s(:), npix(:))';
            expected_pix(obj.VARIANCE_IDX, :) = ...
                expected_pix(obj.VARIANCE_IDX, :) + repelem(dnd_obj.e(:), npix(:))';
            assertElementsAlmostEqual(new_pix_data, expected_pix, 'relative', ...
               4*eps('single'));
        end
    end
end
