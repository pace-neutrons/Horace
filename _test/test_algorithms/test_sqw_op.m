classdef test_sqw_op < TestCaseWithSave

    properties (Constant)
        FLOAT_TOL = 1e-5;
        DOUBLE_TOL = 1e-8;
    end

    properties
        sqw_2d_obj;
        sqw_2d_file = 'sqw_2d_1.sqw';
        dnd_file    = 'w3d_d3d.sqw';
        sqw_2d_pix_pg_size = floor(3e5/36); % Gives us 6 pages used in filebacked operations

        gauss_sqw_fun;
        gauss_sigma;
        linear_func;
        linear_params;
    end

    methods

        function obj = test_sqw_op(varargin)
            if nargin<1
                opt = 'test_sqw_op';
            else
                opt = varargin{1};
            end
            % second parameter describes the source of the reference data
            % currently it is uses as input for assertEqualWithSave, but
            % when data_sqw_dnd_changes, these data should be used as input
            % to support loading the previous version
            obj = obj@TestCaseWithSave(opt,'test_sqw_op_ref_data.mat');


            % 4D gaussian in the centre of pixel data block in 4 dimensions
            obj.gauss_sqw_fun = ...
                @(op, pars)test_sqw_op.page_gauss(op,pars);
            obj.gauss_sigma = [0.1, 0.05, 100,100]; % gaussian in qx,qy,
            % almost constant in qz,dE directions. Centre defined by
            % function

            % Sum of multiple of each coordinate
            obj.linear_func = ...
                @(u1, u2, u3, dE, pars) sum([u1, u2, u3, dE].*pars, 2);
            obj.linear_params = [2, 1, 1, 4];

            hps = horace_paths;
            obj.sqw_2d_file= fullfile(hps.test_common,obj.sqw_2d_file);
            obj.dnd_file   = fullfile(hps.test_common,obj.dnd_file);

            obj.sqw_2d_obj = read_sqw(obj.sqw_2d_file);
            % Binning is more accurate now, so pixels are distributed into
            % sligtly different bins. Reference data are not entirely
            % accurate due to binning errors. To compare operations,
            % recalculate according to modern standards
            obj.sqw_2d_obj  = obj.sqw_2d_obj.recompute_bin_data();
            obj.save();
        end

        %------------------------------------------------------------------
        % Argument validation tests -- Majority are the same as for test_sqw_eval
        % so look there for missing checks
        function test_notEnoughOutputs_error_if_no_ret_value_and_filebacked(obj)
            f = @() sqw_op( ...
                obj.sqw_2d_obj, ...
                obj.gauss_sqw_fun, ...
                obj.gauss_sigma, ...
                'filebacked', true ...
                );
            assertExceptionThrown(f, 'HORACE:sqw_op:invalid_argument');
        end
        %------------------------------------------------------------------
        % SQW file tests
        function test_gauss_on_sqw_file_matches_reference_file(obj)
            out_sqw = sqw_eval(obj.sqw_2d_file_path, obj.gauss_sqw_fun, obj.gauss_params);

            assertEqualToTol( ...
                out_sqw, obj.sqw_2d_sqw_eval_ref_obj, obj.FLOAT_TOL, ...
                'ignore_str', true ...
                );
        end

        function test_gauss_on_sqw_file_with_all_flag_ignores_the_flag(obj)
            out_sqw = sqw_eval( ...
                obj.sqw_2d_file_path, obj.gauss_sqw_fun, obj.gauss_params, '-all' ...
                );

            assertEqualToTol( ...
                out_sqw, obj.sqw_2d_sqw_eval_ref_obj, obj.FLOAT_TOL, ...
                'ignore_str', true ...
                );
        end

        function test_gauss_on_cell_of_sqw_files_matches_reference_file(obj)
            sqws_in = {obj.sqw_2d_file_path, obj.sqw_2d_file_path};

            out_sqw = sqw_eval(sqws_in, obj.gauss_sqw_fun, obj.gauss_params);

            assertEqual(size(out_sqw), size(sqws_in));
            for i = 1:numel(sqws_in)
                assertEqualToTol( ...
                    out_sqw(i), obj.sqw_2d_sqw_eval_ref_obj, obj.FLOAT_TOL, ...
                    'ignore_str', true ...
                    );
            end
        end

        function test_filebacked_pix_matches_reference_object_with_no_mex(obj)
            conf_cleanup = set_temporary_config_options(hor_config, ...
                'mem_chunk_size', obj.sqw_2d_pix_pg_size, ...
                'use_mex', false ...
                );

            out_sqw = sqw_eval( ...
                obj.sqw_2d_file_path, obj.gauss_sqw_fun, obj.gauss_params, ...
                'filebacked', true ...
                );
            assertTrue(isa(out_sqw.pix,'PixelDataFileBacked'));

            ref_obj = obj.sqw_2d_sqw_eval_ref_obj;

            assertEqualToTol( ...
                out_sqw, ref_obj, obj.FLOAT_TOL, ...
                'ignore_str', true,'-ignore_date' ...
                );
        end

        function test_gauss_on_sqw_w_filebacked_and_ave_equal_to_in_memory(obj)
            conf_cleanup = set_temporary_config_options( ...
                hor_config, 'mem_chunk_size', obj.sqw_2d_pix_pg_size ...
                );

            % In this function we just test equivalence between in-memory and
            % file-backed.
            % We test that the in-memory is correct in:
            % test_calling_with_average_flag_sets_each_pix_signal_to_average
            fb_out_sqw = sqw_op( ...
                obj.sqw_2d_file_path, obj.gauss_sqw_fun, obj.gauss_sigma, ...
                'filebacked', true ...
                );
            assertTrue(isa(fb_out_sqw.pix,'PixelDataFileBacked'));

            ref_out_sqw = sqw_op( ...
                obj.sqw_2d_obj, obj.gauss_sqw_fun, obj.gauss_sigma);
            assertTrue(isa(ref_out_sqw.pix,'PixelDataMemory'));

            assertEqualToTol( ...
                fb_out_sqw, ref_out_sqw, ...
                'tol', obj.FLOAT_TOL, ...
                '-ignore_str','-ignore_date' ...
                );
        end
        %------------------------------------------------------------------
        % SQW object tests
        function test_gauss_on_sqw_object_matches_reference_file(obj)
            out_sqw = sqw_eval(obj.sqw_2d_obj, obj.gauss_sqw_fun, obj.gauss_params);

            assertEqualToTol( ...
                out_sqw, obj.sqw_2d_sqw_eval_ref_obj, obj.FLOAT_TOL, ...
                'ignore_str', true ...
                );
        end

        function test_gauss_on_array_of_sqw_objects_matches_reference_file(obj)
            sqws_in = [obj.sqw_2d_obj, obj.sqw_2d_obj];

            out_sqw = sqw_eval(sqws_in, obj.gauss_sqw_fun, obj.gauss_params);

            assertEqual(size(out_sqw), size(sqws_in));
            for i = 1:numel(sqws_in)
                assertEqualToTol( ...
                    out_sqw(i), obj.sqw_2d_sqw_eval_ref_obj, obj.FLOAT_TOL, ...
                    'ignore_str', true ...
                    );
            end
        end
        %
        function test_output_is_file_if_filebacked_true_and_pix_in_memory(obj)
            out_sqw = sqw_op( ...
                obj.sqw_2d_obj, obj.gauss_sqw_fun, obj.gauss_sigma,...
                 'filebacked', true);

            assertEqualToTolWithSave(obj,out_sqw,...
                obj.FLOAT_TOL, '-ignore_str','-ignore_date');
        end        
        function test_gauss_on_sqw_in_mem_is_equal_to_reference(obj)

            out_sqw = sqw_op(obj.sqw_2d_obj, ...
                obj.gauss_sqw_fun,obj.gauss_sigma);

            assertTrue(isa(out_sqw.pix,'PixelDataMemory'));

            % my custom function does not change variange, just
            % recalculates it, so it should remain the same.
            assertEqualToTol(obj.sqw_2d_obj.data.e,out_sqw.data.e);

            assertEqualToTolWithSave(obj,out_sqw, ...
                'tol', obj.FLOAT_TOL, '-ignore_str','-ignore_date');
        end
    end
    %----------------------------------------------------------------------
    % DND tests or some undefined input -- test fails gracefully
    methods
        function test_sqw_op_on_dnd_fails(obj)
            fake_dnd = {d4d()};

            assertExceptionThrown(@()sqw_op(fake_dnd,obj.linear_func,obj.linear_params),...
                'HORACE:sqw_op:invalid_argument');
        end
        function test_sqw_op_on_dnd_file_fails(obj)
            assertExceptionThrown(@()sqw_op(obj.dnd_file,obj.linear_func,obj.linear_params),...
                'HORACE:sqw_op:invalid_argument');
        end

        function test_sqw_op_something_unknown_file_fails(obj)
            assertExceptionThrown(@()sqw_op(10,obj.linear_func,obj.linear_params),...
                'HORACE:sqw_op:invalid_argument');
        end
        function test_sqw_op_wrong_mixture_fails(obj)
            assertExceptionThrown(@()sqw_op({obj.sqw_2d_obj,obj.dnd_file},obj.linear_func,obj.linear_params),...
                'HORACE:sqw_op:invalid_argument');
        end
    end

    methods(Static,Access=protected)
        function page = page_gauss(op,sigma)
            page = op.page_data;
            pix_range = op.pix.pix_range;
            persistent q_idx
            if isempty(q_idx)
                q_idx = PixelDataBase.field_index('coordinates');
            end
            coord = page(q_idx,:);
            center = 0.5*(pix_range(1,:)+pix_range(2,:));
            signal = exp(-sum(((coord-center(:))./sigma(:)).^2,1));
            page(op.signal_idx,:) = signal;
        end

    end
end
