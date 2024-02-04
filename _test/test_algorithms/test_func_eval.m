classdef test_func_eval < TestCase & common_state_holder

    properties (Constant)
        FLOAT_TOL = 1e-5;
    end

    properties

        d2d_file_path;
        d2d_obj;
        sqw_1d_file_path;
        sqw_2d_file_path;
        sqw_2d_obj_fb;
        sqw_2d_obj_mb;

        quadratic = @(x1, x2, a, b, c) a*x1.^2 + b*x1 + c + a*x2.^2 + b*x2;
        quadratic_params = {2, 3, 6};
        % Reference data for the final row of the expected output image signal
        final_img_signal_row_sqw_2d = [...
            4.0150, 4.0238, 4.0342, 4.0462, 4.0598, 4.0750, 4.0918, ...
            4.1102, 4.1302, 4.1518, 4.1750 ...
            ];
        final_img_signal_row_dnd = [ ...
            7.5200, 7.5962, 7.6750, 7.7562, 7.8400, 7.9262, 8.0150, 8.1062, ...
            8.2000, 8.2962, 8.3950, 8.4962, 8.6000, 8.7062, 8.8150, 8.9262, ...
            9.0400
            ];
        old_ws
    end

    methods
        function obj = test_func_eval(~)
            obj = obj@TestCase('test_func_eval');
            obj.old_ws = warning('off','HORACE:old_file_format');

            pths = horace_paths;
            obj.sqw_1d_file_path = fullfile(pths.test_common, 'sqw_1d_1.sqw');
            obj.sqw_2d_file_path = fullfile(pths.test_common, 'sqw_2d_1.sqw');
            obj.d2d_file_path = fullfile(pths.test_common, 'w2d_qq_small_d2d.sqw');

            obj.d2d_obj = read_dnd(obj.d2d_file_path);

            obj.sqw_2d_obj_fb = read_sqw(obj.sqw_2d_file_path, '-filebacked');
            obj.sqw_2d_obj_mb = obj.sqw_2d_obj_fb;
            obj.sqw_2d_obj_mb.pix = PixelDataMemory(obj.sqw_2d_obj_fb.pix);

        end
        function delete(obj)
            warning(obj.old_ws);
        end


        %% Input validation
        function test_SQW_error_if_func_handle_arg_is_not_a_function_handle(obj)
            sqw_in = sqw();
            f = @() func_eval(sqw_in, 'not_a_handle', obj.quadratic_params);
            assertExceptionThrown(f, 'MATLAB:InputParser:ArgumentFailedValidation');
        end

        function test_SQW_error_applying_func_eval_to_0D_sqw(obj)
            sqw_in = sqw();
            f = @() func_eval(sqw_in, obj.quadratic, obj.quadratic_params);
            assertExceptionThrown(f, 'HORACE:sqw:invalid_argument');
        end

        function test_SQW_error_if_sqws_in_array_have_different_dimensions(obj)
            sqws_in = [sqw(obj.sqw_1d_file_path), obj.sqw_2d_obj_fb];
            f = @() func_eval(sqws_in, obj.quadratic, obj.quadratic_params);
            assertExceptionThrown(f, 'HORACE:sqw:invalid_argument');
        end

        function test_SQW_error_if_num_input_objects_gt_num_outfiles(obj)
            sqws_in = [obj.sqw_2d_obj_fb, obj.sqw_2d_obj_fb];
            outfile = 'some_path';

            f = @() func_eval( ...
                sqws_in, obj.quadratic, obj.quadratic_params, 'outfile', outfile ...
                );
            assertExceptionThrown(f, 'HORACE:sqw:invalid_argument');
        end

        function test_SQW_error_if_num_input_objects_lt_num_outfiles(obj)
            sqws_in = obj.sqw_2d_obj_fb;
            outfiles = {'some_path', 'some_other_path'};

            f = @() func_eval( ...
                sqws_in, obj.quadratic, obj.quadratic_params, 'outfile', outfiles ...
                );
            assertExceptionThrown(f, 'HORACE:sqw:invalid_argument');
        end

        function test_error_raised_if_func_eval_called_with_mix_of_sqw_and_dnd(obj)
            inputs = {obj.d2d_obj, obj.sqw_2d_obj_fb};
            f = @() func_eval(inputs, obj.quadratic, obj.quadratic_params);
            assertExceptionThrown(f, 'HORACE:func_eval:invalid_argument');
        end

        function test_error_if_func_eval_input_arrays_within_a_cell_array(obj)
            inputs = {[obj.sqw_2d_obj_fb, obj.sqw_2d_obj_fb]};
            f = @() func_eval(inputs, obj.quadratic, obj.quadratic_params);
            assertExceptionThrown(f, 'HORACE:func_eval:invalid_argument');
        end

        %% SQW tests
        function test_applying_func_eval_to_sqw_object_returns_correct_sqw_data(obj)
            sqw_out = obj.sqw_2d_obj_fb.func_eval(obj.quadratic, obj.quadratic_params);

            assertElementsAlmostEqual( ...
                sqw_out.data.s(end, :), ...
                obj.final_img_signal_row_sqw_2d ...
                );
            obj.validate_func_eval_sqw_output(obj.sqw_2d_obj_fb, sqw_out);
        end

        function test_func_eval_on_array_of_sqw_objects_returns_correct_sqw_data(obj)
            sqws_in = repmat(obj.sqw_2d_obj_fb, [2, 3]);
            sqws_out = func_eval(sqws_in, obj.quadratic, obj.quadratic_params);

            assertEqual(size(sqws_out), size(sqws_in));
            for i = 1:numel(sqws_in)
                assertElementsAlmostEqual( ...
                    sqws_out(i).data.s(end, :), ...
                    obj.final_img_signal_row_sqw_2d ...
                    );
                obj.validate_func_eval_sqw_output(obj.sqw_2d_obj_fb, sqws_out(i));
            end
        end

        function test_func_eval_on_array_of_sqw_objs_with_cell_arr_of_outfiles(obj)
            sqws_in = [obj.sqw_2d_obj_fb, obj.sqw_2d_obj_fb];
            outfiles = {gen_tmp_file_path('1'), gen_tmp_file_path('2')};
            tmp_file_cleanup = onCleanup(@() cellfun(@(x) del_memmapfile_files(x), outfiles));

            sqws_out = func_eval(sqws_in, obj.quadratic, obj.quadratic_params, 'outfile', outfiles);

            assertEqual(size(sqws_out), size(sqws_in));
            for i = 1:numel(sqws_in)
                assertEqual(sqws_out(i).pix.full_filename, outfiles{i});

                assertElementsAlmostEqual( ...
                    sqws_out(i).data.s(end, :), ...
                    obj.final_img_signal_row_sqw_2d, ...
                    'relative', obj.FLOAT_TOL ...
                    );

                obj.validate_func_eval_sqw_output(obj.sqw_2d_obj_fb, sqws_out(i));
            end
            clear sqws_out
        end

        function test_applying_func_eval_to_an_sqw_file_returns_correct_sqw_data(obj)
            sqw_out = func_eval(obj.sqw_2d_obj_fb, obj.quadratic, obj.quadratic_params);

            assertElementsAlmostEqual( ...
                sqw_out.data.s(end, :), ...
                obj.final_img_signal_row_sqw_2d ...
                );

            obj.validate_func_eval_sqw_output(obj.sqw_2d_obj_fb, sqw_out);
        end

        function test_applying_func_eval_to_sqw_obj_with_outfile_outputs_to_file(obj)
            outfile = gen_tmp_file_path();

            sqw_out = func_eval( ...
                obj.sqw_2d_obj_fb, ...
                obj.quadratic, ...
                obj.quadratic_params, ...
                'outfile', outfile ...
                );

            tmp_file_cleanup = onCleanup(@() del_memmapfile_files(outfile));

            assertEqual(sqw_out.pix.full_filename, outfile)
            assertTrue(is_file(outfile));

            assertEqualToTol( ...
                sqw_out.data.s(end, :), ...
                obj.final_img_signal_row_sqw_2d, ...
                'reltol', obj.FLOAT_TOL ...
                );
            obj.validate_func_eval_sqw_output(obj.sqw_2d_obj_fb, sqw_out);
        end

        function test_output_file_of_out_of_memory_op_matches_reference_data(obj)
            mem_chunk_size = floor(24689/5); % all pixels from ref file (24689),
            % split in 5-6 pages
            config_cleanup = set_temporary_config_options(hor_config, 'mem_chunk_size', mem_chunk_size);
            sqw_out = func_eval(obj.sqw_2d_obj_fb, obj.quadratic, obj.quadratic_params);

            assertTrue(isa(sqw_out, 'sqw'));

            assertElementsAlmostEqual( ...
                sqw_out.data.s(end, :), ...
                obj.final_img_signal_row_sqw_2d, ...
                'relative', obj.FLOAT_TOL ...
                );
            obj.validate_func_eval_sqw_output(obj.sqw_2d_obj_fb, sqw_out);
        end

        function test_output_on_cell_arr_objects_matches_ref(obj)
            sqws_in = {obj.sqw_2d_obj_mb, obj.sqw_2d_obj_mb};
            sqws_out = func_eval(sqws_in, obj.quadratic, obj.quadratic_params);

            assertTrue(isa(sqws_out, 'sqw'));
            assertEqual(numel(sqws_out), numel(sqws_in));
            for i = 1:numel(sqws_out)
                assertElementsAlmostEqual( ...
                    sqws_out(i).data.s(end, :), ...
                    obj.final_img_signal_row_sqw_2d, ...
                    'relative', obj.FLOAT_TOL ...
                    );
                obj.validate_func_eval_sqw_output(obj.sqw_2d_obj_fb, sqws_out(i));
            end
        end

        function test_outfile_path_equal_to_input_outfile_if_filebacked(obj)
            outfile = gen_tmp_file_path();
            sqw_out = func_eval(obj.sqw_2d_obj_fb, obj.quadratic, obj.quadratic_params, 'outfile', outfile);

            tmp_file_cleanup = onCleanup(@() clean_up_file(outfile));

            assertEqual(sqw_out.pix.full_filename, outfile)
            assertTrue(is_file(outfile));
        end

        function test_npix_all_ones_if_all_flag_given_and_no_pixels(obj)
            sqw_in = obj.sqw_2d_obj_mb;
            sqw_in.pix = PixelDataBase.create();
            sqw_out = func_eval(sqw_in, obj.quadratic, obj.quadratic_params, '-all');

            assertElementsAlmostEqual( ...
                sqw_out.data.s(end, :), ...
                obj.final_img_signal_row_sqw_2d ...
                );
            assertEqual(sqw_out.data.npix, ones(size(obj.sqw_2d_obj_fb.data.npix)));
        end

        function test_output_matches_ref_file_if_pixel_page_size_small(obj)
            mem_chunk_size = floor(24689/5); % all pixels, 5 pages
            config_cleanup = set_temporary_config_options(hor_config, 'mem_chunk_size', mem_chunk_size);

            sqw_out = func_eval(obj.sqw_2d_obj_fb, obj.quadratic, obj.quadratic_params);
            out_file = sqw_out.full_filename;

            assertTrue(sqw_out.pix.is_filebacked)

            assertElementsAlmostEqual( ...
                sqw_out.data.s(end, :), ...
                obj.final_img_signal_row_sqw_2d, ...
                'relative', obj.FLOAT_TOL ...
                );
            obj.validate_func_eval_sqw_output(obj.sqw_2d_obj_fb, sqw_out);
            clear sqw_out
            assertFalse(is_file(out_file));
        end

        %% DnD tests
        function test_applying_func_eval_to_dnd_object_returns_correct_dnd_data(obj)
            dnd_out = func_eval(obj.d2d_obj, obj.quadratic, obj.quadratic_params);

            assertElementsAlmostEqual( ...
                dnd_out.s(end, :), ...
                obj.final_img_signal_row_dnd, ...
                'relative', obj.FLOAT_TOL ...
                );
            obj.validate_func_eval_dnd_output(obj.d2d_obj, dnd_out);
        end

        function test_func_eval_on_array_of_dnd_objects_returns_correct_dnd_data(obj)
            d2ds_in = repmat(obj.d2d_obj, [1, 2]);
            d2ds_out = func_eval(d2ds_in, obj.quadratic, obj.quadratic_params);

            assertEqual(size(d2ds_out), size(d2ds_in));
            for i = 1:numel(d2ds_out)
                assertElementsAlmostEqual( ...
                    d2ds_out(i).s(end, :), ...
                    obj.final_img_signal_row_dnd, ...
                    'relative', obj.FLOAT_TOL ...
                    );
                obj.validate_func_eval_dnd_output(obj.d2d_obj, d2ds_out(i));
            end
        end

        function test_applying_func_eval_to_a_dnd_file_returns_correct_dnd_data(obj)
            dnd_out = func_eval(obj.d2d_obj, obj.quadratic, obj.quadratic_params);

            assertElementsAlmostEqual( ...
                dnd_out.s(end, :), ...
                obj.final_img_signal_row_dnd, ...
                'relative', obj.FLOAT_TOL ...
                );
            obj.validate_func_eval_dnd_output(obj.d2d_obj, dnd_out);
        end

        function test_func_eval_on_cell_array_of_dnd_files_rets_dnd_array(obj)
            dnds_in = {obj.d2d_obj, obj.d2d_obj};
            dnds_out = func_eval(dnds_in, obj.quadratic, obj.quadratic_params);

            assertEqual(size(dnds_out), size(dnds_in));
            for i = 1:numel(dnds_out)
                dnd_out = dnds_out(i);
                assertElementsAlmostEqual( ...
                    dnd_out.s(end, :), ...
                    obj.final_img_signal_row_dnd, ...
                    'relative', obj.FLOAT_TOL ...
                    );
                obj.validate_func_eval_dnd_output(obj.d2d_obj, dnd_out);
            end
        end

        function test_for_dnd_input_npix_are_all_ones_if_all_flag_given(obj)
            dnd_out = func_eval(obj.d2d_obj, obj.quadratic, obj.quadratic_params, '-all');

            assertElementsAlmostEqual( ...
                dnd_out.s(end, :), ...
                obj.final_img_signal_row_dnd, ...
                'relative', obj.FLOAT_TOL ...
                );
            assertEqual(dnd_out.npix, ones(size(obj.d2d_obj.npix)));
        end

        function test_for_dnd_input_npix_are_all_ones_if_kwarg_all_is_true(obj)
            dnd_out = func_eval(obj.d2d_obj, obj.quadratic, obj.quadratic_params, 'all', true);

            assertElementsAlmostEqual( ...
                dnd_out.s(end, :), ...
                obj.final_img_signal_row_dnd, ...
                'relative', obj.FLOAT_TOL ...
                );
            assertEqual(dnd_out.npix, ones(size(obj.d2d_obj.npix)));
        end
    end

    methods (Static)
        function validate_func_eval_sqw_output(sqw_in, sqw_out)
            % Check output image size is equal to input image size
            assertEqual(size(sqw_out.data.s), size(sqw_in.data.s));
            % Check all output errors are zero with equal size to image
            assertEqual(sqw_out.data.e, zeros(size(sqw_in.data.e)));
            % Check that data.npix is unchanged
            assertEqual(sqw_out.data.npix, sqw_in.data.npix);

            sig_var = sqw_out.pix.sig_var;
            % Check that all pixel signals for each bin are equal to the value
            % of the image signal in the corresponding bin
            signal = sig_var(1, :);
            expected_signal = repelem(sqw_out.data.s(:), sqw_out.data.npix(:))';
            assertEqualToTol(signal, expected_signal(1:numel(signal)),3e-7);

            % Check that all pixel variances are set to zero
            variance = sig_var(2, :);
            if sqw_out.pix.is_filebacked && sqw_out.pix.page_size<sqw_out.pix.num_pixels
                assertEqual(variance, zeros(1,sqw_out.pix.page_size));
                % try to clean-up memory to be able to delete target file
                % does not work on all Matlab versions
                sqw_out.pix.delete();
                clear sqw_out;
            else
                assertEqual(variance, zeros(1, sum(sqw_out.data.npix(:))));
            end
        end

        function validate_func_eval_dnd_output(dnd_in, dnd_out)
            % Check output image size is equal to input image size
            assertEqual(size(dnd_in.s), size(dnd_in.s));
            % Check all output errors are zero with equal size to image
            assertEqual(dnd_out.e, zeros(size(dnd_in.e)));
            % Check that data.npix is unchanged
            assertEqual(dnd_out.npix, dnd_in.npix);
        end
    end

end
