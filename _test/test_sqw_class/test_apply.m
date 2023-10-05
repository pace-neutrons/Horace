classdef test_apply < TestCase

    methods
        function obj = test_apply(name)
            if ~exist('name', 'var')
                name = 'test_apply';
            end
            obj = obj@TestCase(name)
        end

        function test_apply_against_unary_pix_no_dnd(obj)

            num_pix = 30;
            data_range = [0, 1];
            data = get_random_data_in_range( ...
                PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix, data_range);
            pix_mb = PixelDataMemory(data);

            pix_un = do_unary_op(pix_mb, @sin);
            pix_ap = apply(pix_mb, @(pix_mb) obj.wrap_unary_func(@sin, pix_mb));

            assertEqualToTol(pix_un, pix_ap)

            pix_fb = PixelDataFileBacked(data);
            pix_ap = apply(pix_fb, @(pix_fb) obj.wrap_unary_func(@sin, pix_fb));

            assertEqualToTol(pix_un, pix_ap, 'tol', [1e-6, 1e-6])
        end

        function test_apply_against_unary_pix(obj)

            num_pix = 30;
            data_range = [0, 1];
            data = get_random_data_in_range( ...
                PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix, data_range);
            sqw_mb = sqw();
            sqw_mb.pix = PixelDataMemory(data);
            sqw_mb.data.npix = num_pix;
            sqw_mb.data.s = -99; % fake data that will be overwritten
            sqw_mb.data.e =  99;

            sqw_un = sin(sqw_mb);
            sqw_ap = apply(sqw_mb, @(sqw_mb) obj.wrap_unary_func(@sin, sqw_mb));

            assertEqualToTol(sqw_un, sqw_ap)

            sqw_fb = sqw();
            sqw_fb.pix = PixelDataFileBacked(data);
            sqw_fb.data.npix = num_pix;
            sqw_fb.data.s = -99; % fake data that will be overwritten
            sqw_fb.data.e =  99;

            sqw_ap = apply(sqw_fb, @(sqw_fb) obj.wrap_unary_func(@sin, sqw_fb));

            assertEqualToTol(sqw_un, sqw_ap, 'tol', [1e-6, 1e-6])
        end

        function test_apply_transform(obj)
            pths = horace_paths();
            pth = fullfile(pths.test_common, 'sqw_2d_1.sqw');
            sqw_mb = sqw(pth);

            clwarn = set_temporary_warning('off', 'HOR_CONFIG:set_fb_scale_factor');
            clob = set_temporary_config_options(hor_config, ...
                                                'mem_chunk_size', 10000, ...
                                                'fb_scale_factor', 1);
            sqw_fb = sqw(pth);

            sym = SymopReflection([1 0 0], [0 1 0]);
            sqw_ap_fb = sqw_fb.apply(@sym.transform_pix, {}, false);
            sqw_ap_mb = sqw_mb.apply(@sym.transform_pix, {}, false);

            sqw_ap_fb.main_header = sqw_ap_mb.main_header;
            sqw_ap_fb.experiment_info = sqw_ap_mb.experiment_info;

            assertEqualToTol(sqw_ap_fb, sqw_ap_mb);
        end

        function test_apply_multiple_transform(~)

            sym = [SymopReflection([1 0 0], [0 1 0]), ...
                   SymopReflection([1 0 0], [0 0 1])];
            func = arrayfun(@(x) @x.transform_pix, sym, 'UniformOutput', false);

            % Apply MB
            sqw_mb = sqw.generate_cube_sqw(10);
            sqw_ap_mb = sqw_mb.apply(func, {}, false);

            % Apply FB
            sqw_fb = sqw_mb;
            sqw_fb.pix = PixelDataFileBacked(sqw_fb.pix);
            sqw_ap_fb = sqw_fb.apply(func, {}, false);

            % Do manually (MB only)
            sqw_op = sqw_mb;
            sqw_op.pix = sym(1).transform_pix(sqw_op.pix);
            sqw_op.pix = sym(2).transform_pix(sqw_op.pix);

            sqw_ap_fb.main_header = sqw_ap_mb.main_header;
            sqw_ap_fb.experiment_info = sqw_ap_mb.experiment_info;

            assertEqualToTol(sqw_op, sqw_ap_mb);
            assertEqualToTol(sqw_ap_fb, sqw_ap_mb);
        end
    end

    methods(Static)
        function pix = wrap_unary_func(unary_op, pix)
            pg_result = unary_op(sigvar(pix.signal, pix.variance));
            pix.signal = pg_result.s;
            pix.variance = pg_result.e;
            pix = pix.recalc_data_range({'signal', 'variance'});
        end
    end
end
