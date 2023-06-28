classdef test_migrated_apis < TestCaseWithSave
    % Collection of placeholder tests to simple run the migrated API functions: these MUST be replaced
    % with more comprehensive tests as soon as possible

    properties
        sqw_file_1d_name = 'sqw_1d_1.sqw';
        sqw_file_2d_name = 'sqw_2d_1.sqw';
        sqw_file_4d_name = 'sqw_4d.sqw';


        test_sqw_1d_fullpath = '';
        test_sqw_2d_fullpath = '';
        test_sqw_4d_fullpath = '';
    end



    methods
        function obj = test_migrated_apis(varargin)
            if nargin == 0
                argi = {'test_migrated_apis'};
            else
                argi = {varargin{1},'test_migrated_apis'};
            end
            obj = obj@TestCaseWithSave(argi{:});
            hc = horace_paths();

            obj.test_sqw_1d_fullpath = fullfile(hc.test_common, obj.sqw_file_1d_name);
            obj.test_sqw_2d_fullpath = fullfile(hc.test_common, obj.sqw_file_2d_name);
            obj.test_sqw_4d_fullpath = fullfile(hc.test_common, obj.sqw_file_4d_name);
            obj.save();
        end

        %% Calculate
        function test_calculate_q_bins_dnd(obj)
            dnd_obj = read_dnd(obj.test_sqw_2d_fullpath);
            [q, en] = calculate_q_bins(dnd_obj);
            assertEqual(size(q), [1,3]);
            assertEqual(size(q{1}), [176, 1]);
            assertEqual(size(q{2}), [176, 1]);
            assertEqual(size(q{3}), [176, 1]);
            assertEqual(en, 0);
        end
        function test_calculate_q_bins_sqw(obj)
            sqw_obj = read_sqw(obj.test_sqw_2d_fullpath);
            [q, en] = calculate_q_bins(sqw_obj);
            assertEqual(size(q), [1,3]);
            assertEqual(size(q{1}), [176, 1]);
            assertEqual(size(q{2}), [176, 1]);
            assertEqual(size(q{3}), [176, 1]);
            assertEqual(en, 0);
        end

        function test_calculate_qw_bins(obj)
        end

        %% Change
        function test_change_crystal(obj)
        end

        %% Compact/slim
        function test_compact(obj)
        end
        function test_slim(obj)
        end

        %% Cut
        function test_cut(obj)
            skipTest('Incorrect test data for cut');
            dnd_2d_obj = read_dnd(obj.test_sqw_2d_fullpath);
            proj = ortho_proj([1,-1,0], [1,1,0], 'uoffset', [1,1,0], 'type', 'paa');
            range = [0,0.2];    % range of cut
            step = 0.01;        % Q step
            bin = [range(1)+step/2,step,range(2)-step/2];
            width = [-0.15,0.15];  % Width in Ang^-1 of cuts
            ebins = [105,0,115];

            w2 = dnd_2d_obj.cut(proj, bin, width, width, ebins, '-pix');
            %            this.assertEqualToTolWithSave (w2, this.tol_sp,'ignore_str',1);
        end
        function test_cut_sym(obj)
            skipTest('Incorrect test data for cut_sym');
            dnd_2d_obj = read_dnd(obj.test_sqw_2d_fullpath);
            proj = ortho_proj([1,-1,0], [1,1,0], 'uoffset', [1,1,0], 'type', 'paa');
            range = [0,0.2];    % range of cut
            step = 0.01;        % Q step
            bin = [range(1)+step/2,step,range(2)-step/2];
            width = [-0.15,0.15];  % Width in Ang^-1 of cuts
            ebins = [105,0,115];

            w2 = dnd_2d_obj.cut_sym(proj, bin, width, width, ebins, '-pix');
            %            this.assertEqualToTolWithSave (w2, this.tol_sp,'ignore_str',1);
        end

        %% Dimensions
        function test_dimensions_sqw_2d(obj)
            sqw_2d_obj = read_sqw(obj.test_sqw_2d_fullpath);
            [nd, sz] = sqw_2d_obj.dimensions();

            assertEqual(nd, 2);
            assertEqual(sz, size(sqw_2d_obj.data.s));
        end
        function test_dimensions_sqw_4d(obj)
            sqw_4d_obj = read_sqw(obj.test_sqw_4d_fullpath);
            [nd, sz] = sqw_4d_obj.dimensions();

            assertEqual(nd, 4);
            assertEqual(sz, size(sqw_4d_obj.data.s));
        end

        function test_dimensions_dnd_2d(obj)
            dnd_2d_obj = read_dnd(obj.test_sqw_2d_fullpath);
            [nd, sz] = dnd_2d_obj.dimensions();

            assertEqual(nd, 2);
            assertEqual(sz, size(dnd_2d_obj.s));
        end
        function test_dimensions_dnd_4d(obj)
            dnd_4d_obj = read_dnd(obj.test_sqw_4d_fullpath);
            [nd, sz] = dnd_4d_obj.dimensions();

            assertEqual(nd, 4);
            assertEqual(sz, size(dnd_4d_obj.s));
        end


        %% sqw_eval/func_eval/Disp2sqw_eval
        %        function test_func_eval(obj)
        %            % tested in test_eval
        %        end
        %        function test_sqw_eval(obj)
        %            % tested in test_eval
        %        end
        %        function test_disp2sqw_eval(obj)
        %            % tested in test_eval
        %        end

        %% Dispersion
        function test_dispersion_with_disp_and_weight_retval(obj)
            dnd_2d_obj = read_dnd(obj.test_sqw_2d_fullpath);
            [wout_disp, wout_weight]  = dispersion(dnd_2d_obj, @test_migrated_apis.disp_rln, {'scale', 10});


            assertEqualToTolWithSave(obj, wout_disp, 'ignore_str', true,'tol',3.e-7);
            assertEqualToTolWithSave(obj, wout_weight, 'ignore_str', true,'tol',1.e-9);
        end
        function test_dispersion_with_disp_return_value_on_dnd(obj)
            params = {'scale', 10};
            dnd_2d_obj = read_dnd(obj.test_sqw_2d_fullpath);
            wout_disp  = dispersion(dnd_2d_obj, @test_migrated_apis.disp_rln, params);

            assertEqualToTolWithSave(obj, wout_disp, 'ignore_str', true,'tol',3.e-7);
        end


        function test_get_proj_and_pbin(obj)
            dnd_2d_obj = read_dnd(obj.test_sqw_2d_fullpath);

            dnd_tst = dnd_tester(dnd_2d_obj);
            [proj,pbin] = dnd_tst.get_proj_and_pbin_pub();

            % Reference data calculated from call on old class
            expected_pbin = {[-0.7, 0.02, -0.4],  [-0.65, 0.02, -0.45], [-0.05, 0.05], [-0.25, 0.25]};
            expected_proj = ortho_proj('alatt',4.2275,'angdeg',90, ...
                'u',[1,1,0],'v',[0,0,1], ...
                'type', 'ppr', ...
                'nonorthogonal', 0, ...
                'label', {'\zeta'  '\xi'  '\eta'  'E'});

            % low tolerance as ref data to 5sf only
            assertEqualToTol(proj, expected_proj, 1e-6);
            assertEqualToTol(pbin, expected_pbin, 1e-6);
        end

        %% split/join
        %function test_split(obj)
        %    % tested in test_join
        %end
        %function test_join(obj)
        %    % tested in test_join
        %end
        %function test_split_and_join(obj)
        %    % tested in test_join
        %end

        %% mask
        %function test_mask(obj)
        %    % tested in test_mask
        %end

        %% xye
        function test_xye_returns_bin_centres_and_errors_sqw(obj)
            sqw_2d_obj = read_sqw(obj.test_sqw_2d_fullpath);
            result = sqw_2d_obj.xye();

            assertEqualToTolWithSave(obj, result,'tol',1.e-7);
        end

        function test_xye_returns_bin_centres_and_errors(obj)
            dnd_2d_obj = read_dnd(obj.test_sqw_2d_fullpath);
            result = dnd_2d_obj.xye();

            assertEqualToTolWithSave(obj,result,'tol',1.e-7);
        end

        function test_xye_sets_NaN_default_null_value(obj)
            dnd_2d_obj = read_dnd(obj.test_sqw_2d_fullpath);

            result = dnd_2d_obj.xye();

            assertEqual(result.y(1,1), NaN);
        end

        function test_xye_sets_user_specified_null_value(obj)
            dnd_2d_obj = read_dnd(obj.test_sqw_2d_fullpath);

            null_value = -1;
            result = dnd_2d_obj.xye(null_value);

            assertEqual(result.y(1,1), null_value);
        end
    end

    methods(Static)
        function val = disp_rln(qh, qk, ql, varargin)
            % simple function to testing; uses the first keyword argument
            scale = varargin{2};
            val = qh .* qk .* ql .* scale;
        end
    end
end
