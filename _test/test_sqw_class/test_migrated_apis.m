classdef test_experiment < TestCaseWithSave
    % Collection of placeholder tests to simple run the migrated API functions: these MUST be replaced
    % with more comprehensive tests as soon as possible
    methods

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
        end
        function test_get_inst_class(obj)
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
        function test_split_and_join(obj)
            sqw_obj = sqw(obj.sqw_filename);
            split_obj = split(sqw_obj);
            reformed_obj = join(split_obj);

            assertEqualToTol(sqw_obj, reformed_obj);

        %% mask
        function test_mask()
        end

        %% sets
        function test_set_efix(obj)
        end
        function test_set_instrument(obj)
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
        end
        function test_xye(obj)
        end
    end
end
