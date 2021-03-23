classdef test_eval < TestCase
    % Series of tests to check the call to user functions always obey the
    % same interface

    properties
        data_dir
        sqw_obj
    end

    methods
        function obj=test_eval(varargin)
            obj = obj@TestCase('test_eval');
            obj.data_dir = fullfile(fileparts(fileparts(mfilename('fullpath'))),'test_sqw_file');
            test_sqw_file = fullfile(obj.data_dir, 'sqw_2d_2.sqw');
            obj.sqw_obj = sqw(test_sqw_file);
        end

        function test_disp2sqw_eval(obj)
            err_message = '';
            try
                ds = disp2sqw_eval(obj.sqw_obj, ...
                    @test_eval.disp2sqw_eval_tester2D, [], 1.0, 'all');
                failed = false;
            catch ME
                failed = true;
                err_message = ME.message;
            end
            assertFalse(failed, err_message);
        end

        function test_func_eval_sqw(obj)
            %
            err_message = '';
            try
                ds = func_eval(obj.sqw_obj, ...
                    @test_eval.funceval_tester2D, [], '-all');
                failed = false;
            catch ME
                failed = true;
                err_message = ME.message;
            end
            assertFalse(failed, err_message);

            sig = ds.data.s;
            assertEqual(sig(1), numel(sig));
            assertEqual(sig(2), 1);

            pix = ds.data.pix;
            assertEqual(pix.signal(1), numel(sig));
            assertEqual(pix.signal(2), numel(sig));

        end

        function test_sqw_eval_aver(obj)
            %
            err_message = '';
            try
                ds = sqw_eval(obj.sqw_obj, ...
                    @test_eval.sqw_eval_tester, [], 'av');
                failed = false;
            catch ME
                failed = true;
                err_message = ME.message;
            end
            assertFalse(failed, err_message);

            sig = ds.data.s;
            pix = ds.data.pix;

            assertEqual(sig(1), numel(sig));
            assertEqual(sig(1), pix.signal(1));
            assertEqual(pix.signal(2), sig(1));
        end

        function test_sqw_eval(obj)
            %
            err_message = '';
            try
                ds = sqw_eval(obj.sqw_obj, ...
                    @test_eval.sqw_eval_tester, []);
                failed = false;
            catch ME
                failed = true;
                err_message = ME.message;
            end
            assertFalse(failed,err_message);

            pix = ds.data.pix;
            assertEqual(pix.signal(2), 1);
            assertEqual(size(pix.data, 2), pix.signal(1));
        end

        function test_sqw_eval_no_pix(obj)
            %
            err_message = '';
            sqw_nopix = copy(obj.sqw_obj);
            sqw_nopix.data.pix = PixelData();
            try
                ds = sqw_eval(obj.sqw_obj, ...
                    @test_eval.sqw_eval_tester, []);
                failed = false;
            catch ME
                failed = true;
                err_message = ME.message;
            end
            assertFalse(failed,err_message);

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
            if any(sz ~= size(k)) || any(sz ~=size(l)) || any(sz ~= size(en))
                error('SQW_EVAL_TESTER:runtime_error', 'unequal size input arrays');
            end
            if size(h,2) ~= 1
                error('SQW_EVAL_TESTER:runtime_error','incorrect shape of input arrays');
            else
                dis = ones(size(h));
            end
            dis(1) = numel(h);
        end

        function [w,s] = disp2sqw_eval_tester2D(qh,qk,ql,p)
            w = ones(size(qh));
            s = ones(size(qh));
        end

        function dis = funceval_tester2D(x, en, par)
            sz = size(x);
            if any(sz ~= size(en))
                error('FUNC_EVAL_TESTER:runtime_error','unequal size input arrays');
            end
            if size(x,2) ~= 1
                error('FUNC_EVAL_TESTER:runtime_error','incorrect shape of input arrays');
            else
                dis = ones(size(x));
            end
            dis(1) = numel(x);
        end
    end
end
