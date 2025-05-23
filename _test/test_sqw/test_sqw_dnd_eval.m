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
            clOb = set_temporary_config_options('hpc_config','parallel_multifit',0);

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
            pix_sig = ds.pix.signal;

            assertEqual(sig, 5.*ones(size(sig)));
            assertEqual(pix_sig, 5.*ones(size(pix_sig)));
        end

        function test_dispersion_sqw(obj)
            skipTest("New dnd objects to caclulate dispersion are not implemented");

            ds = dispersion(obj.sqw_4_test,@obj.sqw_disp_tester,[]);

            sig = ds.data.s;
            pix = ds.pix;
            assertTrue(isempty(pix));

            assertEqual(sig(2),1);
            assertEqual(sig(1),size(obj.sqw_4_test.data.s,1));

        end

        function test_fit_sqw_sqw(obj)
            clOb = set_temporary_config_options('hpc_config','parallel_multifit',0);

            kk = multifit_sqw_sqw(obj.sqw_4_test);
            kk = kk.set_fun (@obj.sqw_eval_tester);
            kk = kk.set_pin(1);
            kk = kk.set_bfun (@obj.sqw_eval_tester);
            kk = kk.set_bpin(1);

            ds = kk.simulate();

            sig = ds.data.s;
            pix_sig = ds.pix.signal;

            assertEqual(sig, 6.*ones(size(sig)));
            assertEqual(pix_sig, 6.*ones(size(pix_sig)));

        end

        function test_fit_sqw(obj)
            clOb = set_temporary_config_options('hpc_config','parallel_multifit',0);            

            kk = multifit_sqw(obj.sqw_4_test);
            kk = kk.set_fun (@obj.sqw_eval_tester);
            kk = kk.set_pin(1);
            kk = kk.set_bfun (@obj.funceval_tester2D);
            kk = kk.set_bpin(1);

            ds = kk.simulate();

            sig = ds.data.s;
            pix_sig = ds.pix.signal;

            assertEqual(sig, 5.*ones(size(sig)));
            assertEqual(pix_sig, 5.*ones(size(pix_sig)));

        end

        function test_fit_func(obj)
            clOb = set_temporary_config_options('hpc_config','parallel_multifit',0);            
            kk = multifit (obj.sqw_4_test);
            kk = kk.set_fun (@obj.funceval_tester2D);
            kk = kk.set_pin(1);
            kk = kk.set_bfun (@obj.funceval_tester2D);
            kk = kk.set_bpin (1);

            my_fitted_data = kk.simulate();

            sig = my_fitted_data.data.s;
            assertEqual(sig, 4.*ones(size(sig)));

        end
        function test_func_eval_dnd(obj)
            clOb = set_temporary_config_options('hpc_config','parallel_multifit',0);            
            ds = func_eval(obj.dnd_4_test, @obj.funceval_tester2D, []);

            sig = ds.s;
            assertEqual(sig, 2.*ones(size(sig)));
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
