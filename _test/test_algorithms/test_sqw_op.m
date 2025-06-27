classdef test_sqw_op < TestCaseWithSave

    properties (Constant)
        FLOAT_TOL = 0.0006;
        DOUBLE_TOL = 1e-8;
    end

    properties
        sqw_2d_obj;
        sqw_2d_file = 'sqw_2d_2.sqw';
        dnd_file    = 'w3d_d3d.sqw';
        sqw_2d_pix_pg_size = floor(3e5/36); % Gives us 6 pages used in filebacked operations

        gauss_sqw_fun;
        gauss_sigma;
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
            this_folder = fileparts(mfilename("fullpath"));
            obj = obj@TestCaseWithSave(opt,fullfile(this_folder,'test_sqw_op_ref_data.mat'));


            % 4D gaussian in the centre of pixel data block in 4 dimensions
            obj.gauss_sqw_fun = ...
                @(op, pars)test_sqw_op.page_gauss(op,pars);
            obj.gauss_sigma = [0.5, 0.5, 100,10]; % gaussian in qx,qy,
            % almost constant in qz,dE directions. Centre defined by
            % function

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
        function test_gauss_on_sqw_w_filebacked_and_ave_equal_to_in_memory(obj)
            % change source configuration to make source object filebacked
            conf_cleanup = set_temporary_config_options( ...
                hor_config, 'mem_chunk_size', obj.sqw_2d_pix_pg_size, ...
                'fb_scale_factor',5 ...
                );

            % In this function we just test equivalence between in-memory and
            % file-backed.
            % We test that the in-memory is correct in:
            % test_calling_with_average_flag_sets_each_pix_signal_to_average
            fb_out_sqw = sqw_op( ...
                obj.sqw_2d_file, obj.gauss_sqw_fun, obj.gauss_sigma, ...
                'filebacked', true ...
                );
            assertTrue(fb_out_sqw.is_filebacked);

            clear conf_cleanup; % clear small chunk config limit to avoid
            % warning about data chunk beeing too big to fit memory
            ref_out_sqw = sqw_op( ...
                obj.sqw_2d_obj, obj.gauss_sqw_fun, obj.gauss_sigma);
            assertFalse(ref_out_sqw.is_filebacked);

            assertEqualToTol(fb_out_sqw, ref_out_sqw, ...
                'tol', obj.FLOAT_TOL, '-ignore_str','-ignore_date');
        end
        %------------------------------------------------------------------
        % SQW object tests
        function test_gauss_on_array_of_sqw_objects_matches_reference_file(obj)
            sqws_in = [obj.sqw_2d_obj, obj.sqw_2d_obj];

            out_sqw = sqw_op(sqws_in, obj.gauss_sqw_fun, obj.gauss_sigma);

            assertEqual(size(out_sqw), size(sqws_in));
            assertEqualToTolWithSave(obj,out_sqw(1),...
                obj.FLOAT_TOL, '-ignore_str','-ignore_date');
            assertEqualToTol(out_sqw(1),out_sqw(2),obj.FLOAT_TOL)

        end
        %
        function test_output_filebacked_ignored_if_fb_true_and_pix_in_memory(obj)
            clWa = set_temporary_warning('off','HORACE:filebacked_ignored');
            out_sqw = sqw_op( ...
                obj.sqw_2d_obj, obj.gauss_sqw_fun, obj.gauss_sigma,...
                'filebacked', true);
            assertFalse(out_sqw.is_filebacked)
            [~,lw] = lastwarn;
            assertEqual(lw,'HORACE:filebacked_ignored')

            assertEqualToTolWithSave(obj,out_sqw,...
                obj.FLOAT_TOL, '-ignore_str','-ignore_date');
        end
        function test_gauss_on_sqw_in_mem_with_nopix_is_equal_to_ref_dnd(obj)

            out_dnd = sqw_op(obj.sqw_2d_obj, ...
                obj.gauss_sqw_fun,obj.gauss_sigma,'-nopix');

            assertTrue(isa(out_dnd,'DnDBase'));

            % my custom function does not change variange, just
            % recalculates it, so it should remain the same.
            assertEqualToTol(obj.sqw_2d_obj.data.e,out_dnd.e,obj.FLOAT_TOL);

            if obj.save_output
                %This test does not work in save mode as reference dataset
                %may not be available.
                return;
            end
            % get reference dataset obtained previously for different test
            % which calculates and returns full sqw object
            ref_sqw = obj.getReferenceDataset('test_gauss_on_sqw_in_mem_is_equal_to_reference','out_sqw');

            assertEqualToTol(ref_sqw.data,out_dnd, ...
                'tol', obj.FLOAT_TOL, '-ignore_str','-ignore_date');
        end


        function test_gauss_on_sqw_in_mem_is_equal_to_reference(obj)

            out_sqw = sqw_op(obj.sqw_2d_obj, ...
                obj.gauss_sqw_fun,obj.gauss_sigma);

            assertTrue(isa(out_sqw.pix,'PixelDataMemory'));

            % my custom function does not change variange, just
            % recalculates it, so it should remain the same.
            assertEqualToTol(obj.sqw_2d_obj.data.e,out_sqw.data.e,obj.FLOAT_TOL);

            assertEqualToTolWithSave(obj,out_sqw, ...
                'tol', obj.FLOAT_TOL, '-ignore_str','-ignore_date');
        end

    end
    %----------------------------------------------------------------------
    % DND tests or some undefined input -- test fails gracefully
    methods
        function test_sqw_op_on_dnd_fails(obj)
            fake_dnd = {d4d()};

            assertExceptionThrown(@()sqw_op(fake_dnd,obj.gauss_sqw_fun,obj.gauss_sigma),...
                'HORACE:algorithms:invalid_argument');
        end
        function test_sqw_op_on_dnd_file_fails(obj)
            assertExceptionThrown(@()sqw_op(obj.dnd_file,obj.gauss_sqw_fun,obj.gauss_sigma),...
                'HORACE:algorithms:invalid_argument');
        end

        function test_sqw_op_something_unknown_file_fails(obj)
            assertExceptionThrown(@()sqw_op(10,obj.gauss_sqw_fun,obj.gauss_sigma),...
                'HORACE:algorithms:invalid_argument');
        end
        function test_sqw_op_wrong_mixture_fails(obj)
            assertExceptionThrown(@()sqw_op({obj.sqw_2d_obj,obj.dnd_file},obj.gauss_sqw_fun,obj.gauss_sigma),...
                'HORACE:algorithms:invalid_argument');
        end
    end

    methods(Static,Access=protected)
        function sig_var = page_gauss(op,gauss_sigma)
            % function-sample used to calculate function of interest over
            % pixels page.
            page = op.page_data;
            pix_range = op.pix.pix_range;
            if any(isinf(pix_range(:))) % this is test file and we use
                % horace_v2 reference file to get test reference data.
                % Filebacked data of this kind do not contain image range.
                % To simplify test architecture, let's specify correct
                % ranges for this reference file here
                pix = op.pix.recalc_data_range('all');
                pix_range = pix.pix_range;
            end
            persistent q_idx
            if isempty(q_idx)
                q_idx = PixelDataBase.field_index('coordinates');
            end
            coord = page(q_idx,:);
            center = 0.5*(pix_range(1,:)+pix_range(2,:));
            signal = exp(-sum(((coord-center(:))./gauss_sigma(:)).^2,1))/(prod(gauss_sigma)*pi*pi);
            sig_var = [signal;page(op.var_idx,:)];
        end
    end
end
