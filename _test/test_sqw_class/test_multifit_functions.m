classdef test_multifit_functions < TestCase
    % Series of tests to check the call to user functions always obey the
    % same interface.
    % Originally in test_sqw/test_sqw_dnd_eval.m; moved to emphasize test
    % on the new SQW class, and provide it with a meaningful name.
    % Only the *fit tests have been used; the dispersion, eval cases are
    % left in test_sqw_dnd_eval.

    properties
        data_dir
        dnd_4_test
        sqw_4_test
    end

    methods
        function obj=test_multifit_functions(name)
            if nargin<1
                name = 'test_multifit_functions';
            end
            obj = obj@TestCase(name);
            obj.data_dir = fullfile(fileparts(fileparts(mfilename('fullpath'))),'common_data');
            test_sqw_file = fullfile(obj.data_dir,'sqw_2d_2.sqw');
            obj.sqw_4_test = sqw(test_sqw_file); % the original of this line, read_sqw(test_sqw_file), did not work;
        end

        function test_tobyfit(obj)
            sample=IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.04,0.03,0.02]);
            sample.alatt = [2.8700 2.8700 2.8700];
            sample.angdeg = [90 90 90];
            obj.sqw_4_test = ...
                set_instrument(obj.sqw_4_test, @maps_instrument,'-efix',800,'S');
            obj.sqw_4_test = ...
                set_sample(obj.sqw_4_test,sample);


            kk = tobyfit(obj.sqw_4_test);
            kk = kk.set_fun (@obj.sqw_eval_tester);
            kk = kk.set_pin(1);
            kk = kk.set_bfun (@obj.funceval_tester2D);
            kk = kk.set_bpin (1);

            ds = kk.simulate();

            sig = ds.data.s;
            pix = ds.pix;
            assertEqual(pix.signal(2),numel(sig)+1);
            assertEqual(pix.num_pixels + numel(sig),pix.signal(1));

            assertEqual(sig(2),2);
            assertElementsAlmostEqual(sig(1),403.0462,'absolute',0.0001);

        end

        function test_fit_sqw_sqw(obj)
            %
            kk = multifit_sqw_sqw(obj.sqw_4_test);
            kk = kk.set_fun (@obj.sqw_eval_tester);
            kk = kk.set_pin(1);
            kk = kk.set_bfun (@obj.sqw_eval_tester);
            kk = kk.set_bpin (1);

            ds = kk.simulate();

            sig = ds.data.s;
            pix = ds.pix;
            assertEqual(pix.signal(2),2);
            assertEqual(2*pix.num_pixels,pix.signal(1));

            assertEqual(sig(2),2);
            assertElementsAlmostEqual(sig(1),386.0924,'absolute',0.0001);

        end

        %
        function test_fit_sqw(obj)
            %
            kk = multifit_sqw(obj.sqw_4_test);
            kk = kk.set_fun (@obj.sqw_eval_tester);
            kk = kk.set_pin(1);
            kk = kk.set_bfun (@obj.funceval_tester2D);
            kk = kk.set_bpin (1);

            ds = kk.simulate();

            sig = ds.data.s;
            pix = ds.pix;
            assertEqual(pix.signal(2),numel(sig)+1);
            assertEqual(pix.num_pixels+numel(sig),pix.signal(1));

            assertEqual(sig(2),2);
            assertElementsAlmostEqual(sig(1),403.0462,'absolute',0.0001);

        end


        function test_fit_func(obj)
            kk = multifit (obj.sqw_4_test);
            kk = kk.set_fun (@obj.funceval_tester2D);
            kk = kk.set_pin(1);
            kk = kk.set_bfun (@obj.funceval_tester2D);
            kk = kk.set_bpin (1);

            my_fitted_data = kk.simulate();

            sig = my_fitted_data.data.s;
            assertEqual(sig(2),2);
            assertEqual(sig(1),2*numel(sig));

        end


    end

    methods(Static)
        function dis = sqw_disp_tester(h,k,l,~)
            sz = size(h);
            if any(sz ~= size(k)) || any(sz ~=size(l))
                error('SQW_EVAL:runtime_error','incorrect shape of input arrays');
            end
            if size(h,2) ~=1
                error('SQW_EVAL:runtime_error','incorrect shape of input arrays');
            else
                dis = ones(size(h));
            end
            dis(1) = numel(h);
        end

        function dis = sqw_eval_tester(h,k,l,en,~)
            sz = size(h);
            if any(sz ~= size(k)) || any(sz ~=size(l)) || any(sz ~= size(en))
                error('SQW_EVAL:runtime_error','incorrect shape of input arrays');
            end
            if size(h,2) ~=1
                error('SQW_EVAL:runtime_error','incorrect shape of input arrays');
            else
                dis = ones(size(h));
            end
            dis(1) = numel(h);
        end

        function dis = funceval_tester2D(x,en,~)
            sz = size(x);
            if any(sz ~= size(en))
                error('FUNC_EVAL:runtime_error','incorrect shape of input arrays');
            end
            if size(x,2) ~=1
                error('FUNC_EVAL:runtime_error','incorrect shape of input arrays');
            else
                dis = ones(size(x));
            end
            dis(1) = numel(x);
        end
    end
end
