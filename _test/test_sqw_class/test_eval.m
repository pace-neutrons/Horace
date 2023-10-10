classdef test_eval < TestCase
    % Series of tests to check the call to user functions always obey the
    % same interface

    properties
        sqw_obj;
        sqw_obj_fb;
    end

    methods
        function obj=test_eval(varargin)
            obj = obj@TestCase('test_eval');
            pths = horace_paths;
            test_sqw_file = fullfile(pths.test_common, 'sqw_2d_2.sqw');
            obj.sqw_obj = sqw(test_sqw_file);
            obj.sqw_obj_fb = obj.sqw_obj;
            obj.sqw_obj_fb.pix = PixelDataFileBacked(obj.sqw_obj_fb.pix);

        end

        function test_disp2sqw_eval(obj)
            ds = disp2sqw_eval(obj.sqw_obj, @test_eval.disp2sqw_eval_tester2D, [], 1.0, '-all');

        end

        function test_func_eval_sqw(obj)
            ds = func_eval(obj.sqw_obj, @test_eval.funceval_tester2D, [], '-all');

            sig = ds.data.s;
            pix_s = ds.pix.signal;

            assertEqual(sig, 3.*ones(size(sig)));
            assertEqual(pix_s, 3.*ones(size(pix_s)));

        end

        function test_sqw_eval_average(obj)

            ds = sqw_eval(obj.sqw_obj, @test_eval.sqw_eval_tester, [], '-average');

            sig = ds.data.s;
            pix_s = ds.pix.signal;

            assertEqual(sig, 2.*ones(size(sig)));
            assertEqual(pix_s, 2.*ones(size(pix_s)));
        end

        function test_sqw_eval(obj)

            ds = sqw_eval(obj.sqw_obj, @test_eval.sqw_eval_tester, []);

            sig = ds.pix.signal;
            assertEqual(sig, 2.*ones(size(sig)));
            assertEqual(ds.data.s, 2.*ones(size(ds.data.s)));
            assertEqual(ds.data.e, 2.*zeros(size(ds.data.s)));
        end

        function test_sqw_eval_average_fb(obj)
            clob = set_temporary_config_options(hor_config, 'mem_chunk_size', 8000);

            ds_mb = sqw_eval(obj.sqw_obj, @test_eval.sqw_eval_tester, [], '-average');
            ds_fb = sqw_eval(obj.sqw_obj_fb, @test_eval.sqw_eval_tester, [], '-average');
            assertTrue(isa(ds_fb.pix,'PixelDataFileBacked'))

            assertEqualToTol(ds_mb, ds_fb, 'tol', 1e-6,'ignore_str',true);
        end

        function test_sqw_eval_fb(obj)
            clob = set_temporary_config_options(hor_config, 'mem_chunk_size', 8000);

            ds_mb = sqw_eval(obj.sqw_obj, @test_eval.sqw_eval_tester, []);
            ds_fb = sqw_eval(obj.sqw_obj_fb, @test_eval.sqw_eval_tester, []);
            assertTrue(isa(ds_fb.pix,'PixelDataFileBacked'))

            assertEqualToTol(ds_mb, ds_fb, 'tol', 1e-6,'ignore_str',true);

            fb_res_file = ds_fb.full_filename;
            assertTrue(is_file(fb_res_file))
            clear ds_fb;
            assertFalse(is_file(fb_res_file))
        end


        function test_sqw_eval_no_pix(obj)

            sqw_nopix = copy(obj.sqw_obj);
            sqw_nopix.pix = PixelDataBase.create();
            ds = sqw_eval(sqw_nopix, @test_eval.sqw_eval_tester, []);

            assertEqual(size(ds.data.s), size(sqw_nopix.data.s));
            % the first value is calculated, it doesn't matter what
            % the actual value is for the purpose of this test
            expected = 2.*ones(size(sqw_nopix.data.s));
            assertEqual(ds.data.s, expected);
        end
    end

    methods(Static)
        function [w,s] = disp2sqw_eval_tester2D(qh,qk,ql,p)
            w = ones(size(qh));
            s = ones(size(qh));
        end

        function dis = sqw_eval_tester(h, k, l, en, par)
            sz = size(h);
            if ~isequal(sz, size(k)) || ~isequal(sz, size(l)) || ~isequal(sz, size(en))
                error('SQW_EVAL_TESTER:runtime_error', 'unequal size input arrays');
            end
            if sz(2) ~= 1
                error('SQW_EVAL_TESTER:runtime_error','incorrect shape of input arrays');
            end
            dis = 2.*ones(sz);
        end

        function dis = funceval_tester2D(x, en, par)
            sz = size(x);
            if ~isequal(sz, size(en))
                error('FUNC_EVAL_TESTER:runtime_error','unequal size input arrays');
            end
            if sz(2) ~= 1
                error('FUNC_EVAL_TESTER:runtime_error','incorrect shape of input arrays');
            end
            dis = 3.*ones(sz);
        end
    end
end
