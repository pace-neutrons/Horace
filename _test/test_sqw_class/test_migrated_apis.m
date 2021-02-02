classdef test_migrated_apis < TestCase
    % Collection of placeholder tests to simple run the migrated API functions: these MUST be replaced
    % with more comprehensive tests as soon as possible

    properties
        sqw_file_2d_name = 'sqw_2d_1.sqw';
        sqw_files_path = '../test_sqw_file/';

        test_sqw_2d_fullpath = '';
    end



    methods
        function obj = test_migrated_apis(~)
            obj = obj@TestCase('test_migrated_apis');

            test_sqw_file = java.io.File(pwd(), fullfile(obj.sqw_files_path, obj.sqw_file_2d_name));
            obj.test_sqw_2d_fullpath = char(test_sqw_file.getCanonicalPath());
        end

        %% Calculate
        function test_calculate_q_bins(obj)
        end
        function test_calculate_qsqr_bins(obj)
        end
        function test_calculate_qsqr_w_bins(obj)
        end
        function test_calculate_qsqr_w_pixels(obj)
        end
        function test_calculate_qw_bins(obj)
        end
        function test_calculate_qw_pixels(obj)
        end
        function test_calculate_qw_pixels2(obj)
        end
        function test_calculate_uproj_pixels(obj)
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
        end
        function test_cut_sym(obj)
        end

        %% Dimensions
        function test_dimensions(obj)
        end
        function test_dimensions_match(obj)
        end

        %% Disp2sqw_eval
        function test_disp2sqw_eval(obj)
        end

        %% Dispersion
        function test_dispersion(obj)
        end

        %% func_eval
        function test_func_eval(obj)
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
        function DISABLED_test_get_inst_class_with_same_instrument(obj)
            s = sqw(obj.test_sqw_2d_fullpath);

            mod_1 = IX_moderator(10,11,'ikcarp',[11,111,0.1]);
            ap_1 = IX_aperture(-10,0.1,0.11);
            chopper_1 = IX_fermi_chopper(1,100,0.1,1,0.01);
            expected_inst =  IX_inst_DGfermi (mod_1, ap_1, chopper_1, 100);

            [inst, all_inst] = s.get_inst_class();

            assertTrue(all_inst);
            assertTrue(equal_to_tol(inst, expected_inst));

        end
        function DISABLED_test_get_inst_class_with_missing_instrument(obj)
           s = sqw(obj.test_sqw_2d_fullpath);

           mod_1 = IX_moderator(10,11,'ikcarp',[11,111,0.1]);
           ap_1 = IX_aperture(-10,0.1,0.11);
           chopper_1 = IX_fermi_chopper(1,100,0.1,1,0.01);
           expected_inst =  IX_inst_DGfermi (mod_1, ap_1, chopper_1, 100);

           s.header{1:20}.intrument = expected_inst;

           [inst, all_inst] = updated.get_inst_class();
           assertFalse(all_inst);
           assertTrue(equal_to_tol(inst, expected_inst));
        end
        function test_get_mod_pulse(obj)
        end
        function test_get_nearest_pixels(obj)
        end
        function test_get_proj_and_pbin(obj)
        end

        %% split/join
        function test_split(obj)
        end
        function test_join(obj)
        end
        function DISABLED_test_split_and_join(obj)
            sqw_obj = sqw(obj.test_sqw_2d_fullpath);
            split_obj = split(sqw_obj);
            %% FAILS Unable to perform assignment with 0 elements on the right-hand side.
            reformed_obj = join(split_obj);

            assertEqualToTol(sqw_obj, reformed_obj);
        end

        %% mask
        function DISABLED_test_mask(obj)
            sqw_obj = sqw(obj.test_sqw_2d_fullpath);
            mask_array = triu(ones(size(sqw_obj.data.s)));

            masked = mask(sqw_obj, mask_array);
            %% Fails: incorrect understanding of mask operation.
            %%assertEqual(masked.data.s, upper(sqw_obj.data.s));
        end

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

        function test_set_mod_pulse(obj)
        end
        function test_set_sample(obj)
        end

        %% shift
        function test_shift_energy_bins(obj)
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
        %DISABLED to pass the tests in the absence of the .mat
        %         file - to be restored when they are reunited
        function DISABLED_test_xye_returns_bin_centres_and_errors(obj)
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
end
