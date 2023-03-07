classdef test_eval < TestCase
    % Series of tests to check the call to user functions always obey the
    % same interface

    properties
        sqw_obj;
    end

    methods
        function obj=test_eval(varargin)
            obj = obj@TestCase('test_eval');
            pths = horace_paths;
            test_sqw_file = fullfile(pths.test_common, 'sqw_2d_2.sqw');
            obj.sqw_obj = sqw(test_sqw_file);
        end

        function test_disp2sqw_eval(obj)
            ds = disp2sqw_eval(obj.sqw_obj, ...
                               @test_eval.disp2sqw_eval_tester2D, [], 1.0, '-all');

        end

        function test_func_eval_sqw(obj)
            ds = func_eval(obj.sqw_obj, ...
                           @test_eval.funceval_tester2D, [], '-all');

            sig = ds.data.s;
            assertEqual(sig(1), numel(sig));
            assertEqual(sig(2), 1);

            pix = ds.pix;
            assertEqual(pix.signal(1), numel(sig));
            assertEqual(pix.signal(2), numel(sig));

        end

        function test_sqw_eval_average(obj)

            ds = sqw_eval(obj.sqw_obj, ...
                          @test_eval.sqw_eval_tester, [], '-average');

            sig = ds.data.s;
            pix = ds.pix;

            assertEqual(sig(1), pix.signal(1));
            assertEqual(pix.signal(1), 210);
        end

        function test_sqw_eval(obj)

            ds = sqw_eval(obj.sqw_obj, ...
                          @test_eval.sqw_eval_tester, []);

            pix = ds.pix;
            assertEqual(pix.signal(2), 1);
            assertEqual(size(pix.data, 2), pix.signal(1));
        end

        function test_sqw_eval_no_pix(obj)

            sqw_nopix = copy(obj.sqw_obj);
            sqw_nopix.pix = PixelDataBase.create();
            ds = sqw_eval(sqw_nopix, ...
                          @test_eval.sqw_eval_tester, []);

            assertEqual(size(ds.data.s), size(sqw_nopix.data.s));
            % the first value is calculated, it doesn't matter what
            % the actual value is for the purpose of this test
            expected = ones(size(sqw_nopix.data.s));
            assertEqual(ds.data.s(2:end), expected(2:end));
        end
    end

    methods(Static)
        function dis = sqw_eval_tester(h, k, l, en, par)
            sz = size(h);
            if ~isequal(sz, size(k)) || ~isequal(sz, size(l)) || ~isequal(sz, size(en))
                error('SQW_EVAL_TESTER:runtime_error', 'unequal size input arrays');
            end
            if sz(2) ~= 1
                error('SQW_EVAL_TESTER:runtime_error','incorrect shape of input arrays');
            end
            dis = ones(sz);
            dis(1) = numel(h);
        end

        function [w,s] = disp2sqw_eval_tester2D(qh,qk,ql,p)
            w = ones(size(qh));
            s = ones(size(qh));
        end

        function dis = funceval_tester2D(x, en, par)
            sz = size(x);
            if ~isequal(sz, size(en))
                error('FUNC_EVAL_TESTER:runtime_error','unequal size input arrays');
            end
            if sz(2) ~= 1
                error('FUNC_EVAL_TESTER:runtime_error','incorrect shape of input arrays');
            end
            dis = ones(sz);
            dis(1) = numel(x);
        end
    end
end
