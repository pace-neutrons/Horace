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
        function test_dispersion(obj)
            skipTest('Incorrect test data for dispersion');
            sqw_4d_obj = d2d(obj.test_sqw_4d_fullpath);
            [retval_one, retval_two]  = dispersion(sqw_4d_obj, @test_migrated_apis.desp_rln, {'scale', 14});
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

        %% shifts
        function test_shift_energy_bins(obj)
            skipTest('Incorrect test data for cut');
            sqw_4d_obj = d2d(obj.test_sqw_1d_fullpath);
            wout = sqw_4d_obj.shift_energy_bins(@test_migrated_apis.desp_rln, {'scale', 14});
        end
        function test_shift_pixels(obj)
            skipTest('No test of return value');
            sqw_4d_obj = d2d(obj.test_sqw_4d_fullpath);
            wout  = sqw_4d_obj.shift_pixels(@test_migrated_apis.shift_rln, {});
        end

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
       function val = desp_rln(qw, params)
            scale = params{2};
            val = qw .* scale;
       end
       function val = shift_rln(qh, qk, qw, params)
            val = qw .* qk .* qh;
       end
    end
end
