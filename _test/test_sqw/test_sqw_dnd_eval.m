classdef test_sqw_dnd_eval < TestCase
    % Series of tests to check the call to user functions always obey the
    % same interface

    properties
        data_dir
        dnd_4_test
        sqw_4_test
    end

    methods
        function obj=test_sqw_dnd_eval(name)
            if nargin<1
                name = 'test_sqw_dnd_eval';
            end
            obj = obj@TestCase(name);
            pths = horace_paths;
            obj.data_dir = pths.test_common;
            test_sqw_file = fullfile(obj.data_dir,'sqw_2d_2.sqw');
            obj.sqw_4_test = sqw(test_sqw_file);
            obj.dnd_4_test = read_dnd(test_sqw_file);
        end

        function test_tobyfit(obj)
            %
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
            %[my_fitted_data,a] = kk.fit; % do not fit-- will not
            %converge

            sig = ds.data.s;
            pix = ds.pix;
            assertEqual(pix.signal(2), numel(sig) + 1);
            assertEqual(pix.num_pixels + numel(sig), pix.signal(1));

            assertEqual(sig(2),2);
            assertElementsAlmostEqual(sig(1),403.0462,'absolute',0.0001);

        end



        function test_dispersion_sqw(obj)
            skipTest("New dnd objects to caclulate dispersion are not implemented");
            %
            ds = dispersion(obj.sqw_4_test,@obj.sqw_disp_tester,[]);

            sig = ds.data.s;
            pix = ds.pix;
            assertTrue(isempty(pix));

            assertEqual(sig(2),1);
            assertEqual(sig(1),size(obj.sqw_4_test.data.s,1));


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
            assertEqual(2*pix.num_pixels, pix.signal(1));

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
            assertEqual(pix.num_pixels + numel(sig), pix.signal(1));

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

        function test_func_eval_sqw(obj)
            ds = func_eval(obj.sqw_4_test, @obj.funceval_tester2D, [], '-all');

            sig = ds.data.s;
            assertEqual(sig(2),1);
            assertEqual(sig(1),numel(sig));

            pix = ds.pix;
            assertEqual(pix.signal(2),numel(sig));
            assertEqual(pix.signal(1),numel(sig));

        end

        function test_func_eval_dnd(obj)
            ds = func_eval(obj.dnd_4_test, @obj.funceval_tester2D, []);

            sig = ds.s;
            assertEqual(sig(2),1);
            assertEqual(sig(1),numel(sig));
        end

        function test_sqw_eval_aver(obj)
            ds = sqw_eval(obj.sqw_4_test,@test_sqw_dnd_eval.sqw_eval_tester,[],'-average');

            sig = ds.data.s;
            assertEqual(sig(1),numel(sig));
            pix = ds.pix;
            assertEqual(pix.signal(2),sig(1));
            assertEqual(sig(1),pix.signal(1));
        end


        function test_sqw_eval(obj)
            ds = sqw_eval(obj.sqw_4_test,@test_sqw_dnd_eval.sqw_eval_tester,[]);

            pix = ds.pix;
            assertEqual(pix.signal(2),1);
            assertEqual(pix.num_pixels, pix.signal(1));
        end

        function test_sqw_eval_dnd(obj)
            ds = sqw_eval(obj.dnd_4_test,@test_sqw_dnd_eval.sqw_eval_tester,[]);

            sig = ds.s;
            assertEqual(sig(2),1);
            assertEqual(sig(1),numel(sig));

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