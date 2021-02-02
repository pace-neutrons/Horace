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
%        function test_calculate_q_bins(obj)
%            % tested as part of calc_qsqr_bin call
%        end
        function test_calculate_qsqr_bins(obj)
            sqw_obj = sqw(obj.test_sqw_2d_fullpath);

            [qsqr, en] = sqw_obj.calculate_qsqr_bins();
            assertEqual(size(qsqr), [176, 1]);
            assertEqual(en, 0);
        end
        function test_calculate_qsqr_w_bins(obj)
            sqw_obj = sqw(obj.test_sqw_2d_fullpath);
            qsqr_w = sqw_obj.calculate_qsqr_w_bins();
            assertEqual(size(qsqr_w{1}), [176, 1]);
            assertEqual(size(qsqr_w{2}), [176, 1]);
        end
        function test_calculate_qsqr_w_bins_boundaries(obj)
            sqw_obj = sqw(obj.test_sqw_2d_fullpath);
            qsqr_w = sqw_obj.calculate_qsqr_w_bins('boundaries');
            assertEqual(size(qsqr_w{1}), [204, 1]);
            assertEqual(size(qsqr_w{2}), [204, 1]);
        end
        function test_calculate_qsqr_w_bins_edges(obj)
            sqw_obj = sqw(obj.test_sqw_2d_fullpath);
            qsqr_w = sqw_obj.calculate_qsqr_w_bins('edges');
            assertEqual(size(qsqr_w{1}), [4, 1]);
            assertEqual(size(qsqr_w{2}), [4, 1]);
        end
        function test_calculate_qsqr_w_pixels(obj)
        end
%        function test_calculate_qw_bins(obj)
%            % tested as part of sqw_eval_nopix and calc_qsqr_w_bin calls
%        end
%        function test_calculate_qw_pixels(obj)
%            % tested as part of shift_pixels
%        end
%        function test_calculate_qw_pixels2(obj)
%            % tested as part of calc_qsqr_w_pixels
%        end
%        function test_calculate_uproj_pixels(obj)
%            % tested as part of test_get_nearest_pixels
%        end

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
            sqw_obj = sqw(obj.test_sqw_2d_fullpath);
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
            sqw_obj = sqw(obj.test_sqw_2d_fullpath);
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
        function test_dimensions_sqw_2d(obj)
            sqw_obj = sqw(obj.test_sqw_2d_fullpath);
            [nd, sz] = sqw_obj.dimensions();

            assertEqual(nd, 2);
            assertEqual(sz, size(sqw_obj.data.s));
        end
        function test_dimensions_sqw_4d(obj)
            sqw_obj = sqw(obj.test_sqw_4d_fullpath);
            [nd, sz] = sqw_obj.dimensions();

            assertEqual(nd, 4);
            assertEqual(sz, size(sqw_obj.data.s));
        end

        %% DimensionsMatch
        function test_dimensions_match_returns_true_if_all_equal(obj)
            sqw_obj = sqw(obj.test_sqw_2d_fullpath);
            match_dims = dimensions_match([sqw_obj, sqw_obj]);
            assertTrue(match_dims);
        end
        function test_dimensions_match_returns_true_if_all_equal_to_arg(obj)
            sqw_obj = sqw(obj.test_sqw_2d_fullpath);
            match_dims = dimensions_match([sqw_obj, sqw_obj], 2);
            assertTrue(match_dims);
        end
        function test_dimensions_match_returns_false_if_not_all_equal_to_arg(obj)
            sqw_obj = sqw(obj.test_sqw_2d_fullpath);
            match_dims = dimensions_match([sqw_obj, sqw_obj], 4);
            assertFalse(match_dims);
        end
        function test_dimensions_match_returns_false_if_not_all_equal(obj)
            sqw_2d_obj = sqw(obj.test_sqw_2d_fullpath);
            sqw_4d_obj = sqw(obj.test_sqw_4d_fullpath);
            match_dims = dimensions_match([sqw_2d_obj, sqw_4d_obj]);
            assertFalse(match_dims);
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
            sqw_4d_obj = sqw(obj.test_sqw_4d_fullpath);
            [retval_one, retval_two]  = dispersion(sqw_4d_obj, @test_migrated_apis.desp_rln, {'scale', 14});
        end

        %% gets
        function test_get_efix(obj)
            sqw_obj = sqw(obj.test_sqw_2d_fullpath);

            expected_efix = 34.959999084472656;
            expected_en = struct( ...
               'efix', expected_efix * ones(85,1), ...
               'emode', ones(85,1), ...
               'ave', expected_efix, ...
               'min', expected_efix, ...
               'max', expected_efix, ...
               'relerr', 0);

            [efix, emode, ok, mess, en] = sqw_obj.get_efix();

            assertEqualToTol(efix, expected_efix, 1e-8);
            assertEqualToTol(en, expected_en, 1e-8);
            assertEqual(emode, 1);
            assertTrue(ok)
            assertEqual(mess, '');
        end
        function test_get_inst_class_with_same_instrument(obj)
            s = sqw(obj.test_sqw_2d_fullpath);

            mod_1 = IX_moderator(10,11,'ikcarp',[11,111,0.1]);
            ap_1 = IX_aperture(-10,0.1,0.11);
            chopper_1 = IX_fermi_chopper(1,100,0.1,1,0.01);
            expected_inst =  IX_inst_DGfermi (mod_1, ap_1, chopper_1, 100);
            
            updated = s.set_instrument(expected_inst);
            [inst, all_inst] = updated.get_inst_class();

            assertTrue(all_inst);
            assertTrue(equal_to_tol(inst, expected_inst));

        end
        function test_get_inst_class_with_missing_instrument(obj)
           s = sqw(obj.test_sqw_2d_fullpath);

           mod_1 = IX_moderator(10,11,'ikcarp',[11,111,0.1]);
           ap_1 = IX_aperture(-10,0.1,0.11);
           chopper_1 = IX_fermi_chopper(1,100,0.1,1,0.01);
           expected_inst =  IX_inst_DGfermi (mod_1, ap_1, chopper_1, 100);

           for idx=1:20
               s.header{idx}.intrument = expected_inst;
           end
           
           [inst, all_inst] = s.get_inst_class();
           assertFalse(all_inst);
           assertEqual(inst, '');
        end
%        function test_get_mod_pulse(obj)
%            % tested as part of test_instrument_methods
%        end
        function test_get_nearest_pixels(obj)
            sqw_obj = sqw(obj.test_sqw_2d_fullpath);
            [xp, ip] = sqw_obj.get_nearest_pixels([-0.5, -0.5]);
            assertEqual(size(xp), [1,2]);
            assertEqual(size(ip), [1,1]);
        end
        function test_get_proj_and_pbin(obj)
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

        %% sets
        function test_set_efix(obj)
            sqw_obj = sqw(obj.test_sqw_2d_fullpath);

            expected_energy = 10101010;

            updated = sqw_obj.set_efix(expected_energy);
            assertTrue(all(cellfun(@(x) x.efix, updated.header) == expected_energy));
        end
        function test_set_instrument(obj)
            s = sqw(obj.test_sqw_2d_fullpath);

            mod_1 = IX_moderator(10,11,'ikcarp',[11,111,0.1]);
            ap_1 = IX_aperture(-10,0.1,0.11);
            chopper_1 = IX_fermi_chopper(1,100,0.1,1,0.01);
            expected_inst =  IX_inst_DGfermi (mod_1, ap_1, chopper_1, 100);

            updated = s.set_instrument(expected_inst);
            assertTrue(all(cellfun(@(x) equal_to_tol(x.instrument, expected_inst), updated.header)));
        end

%        function test_set_mod_pulse(obj)
%            % tested as part of test_instrument_methods
%        end
        function test_set_sample(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            sam1=IX_sample('test_sample_name', true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);

            s_updated = s.set_sample(sam1);

            assertEqual(s_updated.header{1}.sample, sam1);
            assertEqual(s_updated.header{end}.sample, sam1);
        end

        %% shifts
        function test_shift_energy_bins(obj)
            skipTest('Incorrect test data for cut');
            sqw_4d_obj = sqw(obj.test_sqw_1d_fullpath);
            wout = sqw_4d_obj.shift_energy_bins(@test_migrated_apis.desp_rln, {'scale', 14});
        end
        function test_shift_pixels(obj)
            skipTest('No test of return value');
            sqw_4d_obj = sqw(obj.test_sqw_4d_fullpath);
            wout  = sqw_4d_obj.shift_pixels(@test_migrated_apis.shift_rln, {});
        end

        %% values
        function test_value(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            % example values pulled from pre-refactor test
            result = s.value([-0.55,-0.5; -0.42, -0.62]);
            expected = [405.2640686035; 155.0066833496];

            assertEqualToTol(result, expected, 1e-8);
        end

        %% xye
        function test_xye_returns_bin_centres_and_errors(obj)
            s = sqw(obj.test_sqw_2d_fullpath);
            result = s.xye();

            expected = load('test_migrated_apis_data.mat', 'xye_test');

            assertEqualToTol(result.x, expected.xye_test.x);
            assertEqualToTol(result.y, expected.xye_test.y);
            assertEqualToTol(result.e, expected.xye_test.e);
        end

        function test_xye_sets_NaN_default_null_value(obj)
            s = sqw(obj.test_sqw_2d_fullpath);

            result = s.xye();

            assertEqual(result.y(1,1), NaN);
        end

        function test_xye_sets_user_specified_null_value(obj)
            s = sqw(obj.test_sqw_2d_fullpath);

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
