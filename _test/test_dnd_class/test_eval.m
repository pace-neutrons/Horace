classdef test_eval < TestCase
    % Series of tests to check the call to user functions always obey the
    % same interface

    properties
        d1d_obj
        d2d_obj
        sqw1d_obj        
        sqw2d_obj
    end

    methods
        function obj=test_eval(varargin)
            obj = obj@TestCase('test_eval');
            hp = horace_paths();
            obj.d1d_obj = read_dnd(fullfile(hp.test_common,'sqw_1d_2.sqw'));
            obj.d2d_obj = read_dnd(fullfile(hp.test_common,'sqw_2d_2.sqw'));
            obj.sqw1d_obj = read_sqw(fullfile(hp.test_common,'sqw_1d_2.sqw'));
            obj.sqw2d_obj = read_sqw(fullfile(hp.test_common,'sqw_2d_2.sqw'));
            
        end
        %
        function test_disp2sqw_eval_sqw(obj)
            err_message = '';
            try
                ds = disp2sqw_eval(obj.sqw2d_obj, ...
                    @test_eval.disp2sqw_eval_tester2D, [], 1.0, '-all');
                failed = false;
            catch ME
                failed = true;
                err_message = ME.message;
            end
            assertFalse(failed, err_message);
        end        
        function test_disp2sqw_eval_dnd(obj)
            err_message = '';
            try
                ds = disp2sqw_eval(obj.d2d_obj, ...
                    @test_eval.disp2sqw_eval_tester2D, [], 1.0, '-all');
                failed = false;
            catch ME
                failed = true;
                err_message = ME.message;
            end
            assertFalse(failed, err_message);
        end
        %
        function test_func_eval_dnd(obj)
            %
            err_message = '';
           try
                ds = func_eval(obj.d2d_obj, ...
                    @test_eval.funceval_tester2D, []);
                failed = false;
           catch ME
               failed = true;
               err_message = ME.message;
           end
            assertFalse(failed,err_message);

            sig = ds.s;
            assertEqual(sig(2),1);
            assertEqual(sig(1),numel(sig));
        end
        %
        function test_sqw_eval_sqw(obj)
            %
            err_message = '';
            try
                ds = sqw_eval(obj.sqw2d_obj, ...
                    @test_eval.sqw_eval_tester, []);
                failed = false;
            catch ME
                failed = true;
                err_message = ME.message;
            end
            assertFalse(failed,err_message);

            assertEqual(size(ds.data.s), size(obj.d2d_obj.s));
            % the first value is calculated, it doesn't matter what
            % the actual value is for the purpose of this test
            expected = ones(size(obj.d2d_obj.s));
            assertEqual(ds.data.s(2:end), expected(2:end));
        end
        
        function test_sqw_eval_dnd(obj)
            %
            err_message = '';
            try
                ds = sqw_eval(obj.d2d_obj, ...
                    @test_eval.sqw_eval_tester, []);
                failed = false;
            catch ME
                failed = true;
                err_message = ME.message;
            end
            assertFalse(failed,err_message);

            assertEqual(size(ds.s), size(obj.d2d_obj.s));
            % the first value is calculated, it doesn't matter what
            % the actual value is for the purpose of this test
            expected = ones(size(obj.d2d_obj.s));
            assertEqual(ds.s(2:end), expected(2:end));
        end
    end
    methods(Static)
        function dis = sqw_eval_tester(h, k, l, en, par)
            sz = size(h);
            if any(sz ~= size(k)) || any(sz ~=size(l)) || any(sz ~= size(en))
                error('SQW_EVAL_TESTER:runtime_error', 'unequal size input arrays');
            end
            if size(h,2) ~=1
                error('SQW_EVAL_TESTER:runtime_error', 'incorrect shape of input arrays');
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
                error('FUNC_EVAL_TESTER:runtime_error', 'unequal size input arrays');
            end
            if size(x,2) ~=1
                error('FUNC_EVAL_TESTER:runtime_error', 'incorrect shape of input arrays');
            else
                dis = ones(size(x));
            end
            dis(1) = numel(x);
        end
    end
end
