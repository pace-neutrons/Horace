classdef test_migrated_apis < TestCase
    % Collection of placeholder tests to simple run the migrated API functions: these MUST be replaced
    % with more comprehensive tests as soon as possible

    properties
        sqw_file_1d_name = 'sqw_1d_1.sqw';
        sqw_file_2d_name = 'sqw_2d_1.sqw';
        sqw_file_4d_name = 'sqw_4d.sqw';
        sqw_files_path = '../test_sqw_file/';

        test_sqw_1d_fullpath = '';
        test_sqw_2d_fullpath = '';
        test_sqw_4d_fullpath = '';
    end



    methods
        function obj = test_migrated_apis(~)
            obj = obj@TestCase('test_migrated_apis');
            obj.test_sqw_1d_fullpath = obj.build_fullpath(obj.sqw_file_1d_name);
            obj.test_sqw_2d_fullpath = obj.build_fullpath(obj.sqw_file_2d_name);
            obj.test_sqw_4d_fullpath = obj.build_fullpath(obj.sqw_file_4d_name);
        end


        function fullpath = build_fullpath(obj, testfile_name)
            test_file = java.io.File(pwd(), fullfile(obj.sqw_files_path, testfile_name));
            fullpath = char(test_file.getCanonicalPath());
        end

        %% Calculate
        function test_calculate_q_bins(obj)
            dnd_obj = d2d(obj.test_sqw_2d_fullpath);
            [q, en] = calculate_q_bins(dnd_obj);
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
            sqw_obj = d2d(obj.test_sqw_2d_fullpath);
            proj = projaxes([1,-1,0], [1,1,0], 'uoffset', [1,1,0], 'type', 'paa');
            range = [0,0.2];    % range of cut
            step = 0.01;        % Q step
            bin = [range(1)+step/2,step,range(2)-step/2];
            width = [-0.15,0.15];  % Width in Ang^-1 of cuts
            ebins = [105,0,115];

            w2 = sqw_obj.cut(proj, bin, width, width, ebins, '-pix');
%            this.assertEqualToTolWithSave (w2, this.tol_sp,'ignore_str',1);
        end
        function test_cut_sym(obj)
            skipTest('Incorrect test data for cut_sym');
            sqw_obj = d2d(obj.test_sqw_2d_fullpath);
            proj = projaxes([1,-1,0], [1,1,0], 'uoffset', [1,1,0], 'type', 'paa');
            range = [0,0.2];    % range of cut
            step = 0.01;        % Q step
            bin = [range(1)+step/2,step,range(2)-step/2];
            width = [-0.15,0.15];  % Width in Ang^-1 of cuts
            ebins = [105,0,115];

            w2 = sqw_obj.cut_sym(proj, bin, width, width, ebins, '-pix');
%            this.assertEqualToTolWithSave (w2, this.tol_sp,'ignore_str',1);
        end

        %% Dimensions
        function test_dimensions_dnd_2d(obj)
            sqw_obj = d2d(obj.test_sqw_2d_fullpath);
            [nd, sz] = sqw_obj.dimensions();

            assertEqual(nd, 2);
            assertEqual(sz, size(sqw_obj.s));
        end
        function test_dimensions_dnd_4d(obj)
            sqw_obj = d4d(obj.test_sqw_4d_fullpath);
            [nd, sz] = sqw_obj.dimensions();

            assertEqual(nd, 4);
            assertEqual(sz, size(sqw_obj.s));
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
        function test_dispersion_with_disp_return_value(obj)
            params = {'scale', 10};
            dnd_2d_obj = d2d(obj.test_sqw_2d_fullpath);
            [wout_disp]  = dispersion(dnd_2d_obj, @test_migrated_apis.disp_rln, params);

            expected = load('test_migrated_apis_data.mat', 'wout_disp');

            assertEqualToTol(expected.wout_disp, wout_disp, 'ignore_str', true);
        end
        function test_dispersion_with_disp_and_weight_retval(obj)
            dnd_2d_obj = d2d(obj.test_sqw_2d_fullpath);
            [wout_disp, wout_weight]  = dispersion(dnd_2d_obj, @test_migrated_apis.disp_rln, {'scale', 10});

            expected = load('test_migrated_apis_data.mat', 'wout_disp', 'wout_weight');

            assertEqualToTol(expected.wout_disp, wout_disp, 'ignore_str', true);
            assertEqualToTol(expected.wout_weight, wout_weight, 'ignore_str', true);
        end

        function test_get_proj_and_pbin(obj)
            dnd_2d_obj = d2d(obj.test_sqw_2d_fullpath);
            [proj, pbin] = dnd_2d_obj.get_proj_and_pbin();

            % Reference data calculated from call on old class
            expected_pbin = {[-0.7, 0.02, -0.4],  [-0.65, 0.02, -0.45], [-0.05, 0.05], [-0.25, 0.25]};
            expected_proj = projaxes( ...
                [1,1,0], [1.1102e-16 1.1102e-16 1], [1 -1 9.9580e-17], ...
                'type', 'ppp', ...
                'nonorthogonal', 0, ...
                'lab', {'\zeta'  '\xi'  '\eta'  'E'});

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
        function test_xye_returns_bin_centres_and_errors(obj)
            s = d2d(obj.test_sqw_2d_fullpath);
            result = s.xye();

            expected = load('test_migrated_apis_data.mat', 'xye_test');

            assertEqualToTol(result.x, expected.xye_test.x);
            assertEqualToTol(result.y, expected.xye_test.y);
            assertEqualToTol(result.e, expected.xye_test.e);
        end

        function test_xye_sets_NaN_default_null_value(obj)
            s = d2d(obj.test_sqw_2d_fullpath);

            result = s.xye();

            assertEqual(result.y(1,1), NaN);
        end

        function test_xye_sets_user_specified_null_value(obj)
            s = d2d(obj.test_sqw_2d_fullpath);

            null_value = -1;
            result = s.xye(null_value);

            assertEqual(result.y(1,1), null_value);
        end
    end

    methods(Static)
       function val = disp_rln(qh, qk, ql, varargin)
           % simple function to testing; uses the first keyword argument
           scale = varargin{2};
           val = qh .* qk .* ql .* scale;
       end
       function val = shift_rln(qh, qk, qw, ~)
           % discard and function parameters that are passed
           val = qw .* qk .* qh;
       end
    end
end
