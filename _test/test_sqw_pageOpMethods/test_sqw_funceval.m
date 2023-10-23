classdef test_sqw_funceval < TestCase
    % Series of tests to check the call to user functions always obey the
    % same interface

    properties
        data_dir
        dnd_4_test
        sqw_4_test
    end

    methods
        function obj=test_sqw_funceval(name)
            if nargin<1
                name = 'test_sqw_funceval';
            end
            obj = obj@TestCase(name);
            pths = horace_paths;
            obj.data_dir = pths.test_common;
            test_sqw_file = fullfile(obj.data_dir,'sqw_2d_2.sqw');
            obj.sqw_4_test = sqw(test_sqw_file);
            obj.dnd_4_test = read_dnd(test_sqw_file);
        end

        function test_func_eval_sqw(obj)
            ds = func_eval(obj.sqw_4_test, @obj.funceval_tester2D, [], '-all');

            sig = ds.data.s;
            pix_sig = ds.pix.signal;

            assertEqual(sig, 2.*ones(size(sig)));
            assertEqual(pix_sig, 2.*ones(size(pix_sig)));

        end

        function test_sqw_eval_aver(obj)
            ds = sqw_eval(obj.sqw_4_test,@obj.sqw_eval_tester,[],'-average');

            sig = ds.data.s;
            assertEqual(sig, 3.*ones(size(sig)));

            pix = ds.pix;
            assertEqual(pix.signal(2),sig(1));
            assertEqual(sig(1),pix.signal(1));
        end

        function test_sqw_eval(obj)
            ds = sqw_eval(obj.sqw_4_test,@obj.sqw_eval_tester,[]);

            sig = ds.pix.signal;

            assertEqual(sig, 3.*ones(size(sig)));
        end
    end

    methods(Static)
        function dis = sqw_disp_tester(h,k,l,~)
            sz = size(h);
            if any(sz ~= size(k)) || any(sz ~=size(l))
                error('SQW_EVAL:runtime_error','incorrect shape of input arrays');
            elseif sz(2) ~=1
                error('SQW_EVAL:runtime_error','incorrect shape of input arrays');
            end
            dis = 3.*ones(sz);
        end

        function dis = sqw_eval_tester(h,k,l,en,~)
            sz = size(h);
            if any(sz ~= size(k)) || any(sz ~=size(l)) || any(sz ~= size(en))
                error('SQW_EVAL:runtime_error','incorrect shape of input arrays');
            elseif sz(2) ~=1
                error('SQW_EVAL:runtime_error','incorrect shape of input arrays');
            end
            dis = 3.*ones(sz);
        end

        function dis = funceval_tester2D(x,en,~)
            sz = size(x);
            if any(sz ~= size(en))
                error('FUNC_EVAL:runtime_error','incorrect shape of input arrays');
            elseif sz(2) ~=1
                error('FUNC_EVAL:runtime_error','incorrect shape of input arrays');
            end
            dis = 2.*ones(sz);
        end
    end
end
