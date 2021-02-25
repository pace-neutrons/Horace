classdef test_sqw_eval < TestCase

    properties (Constant)
        FLOAT_TOL = 1e-5;
    end

    properties
        sqw_2d_file_path = '../test_sqw_file/sqw_2d_1.sqw';
        sqw_2d_sqw_eval_ref_file = 'test_sqw_eval_gauss_ref.sqw';

        sqw_2d_obj;
        sqw_2d_sqw_eval_ref_obj;

        gauss_sqw;
        gauss_params;
        linear_func;
        linear_params;
    end

    methods

        function obj = test_sqw_eval(~)
            obj = obj@TestCase('test_sqw_eval');

            % Sum of the gaussian of each coordinate
            obj.gauss_sqw = ...
                @(u1, u2, u3, dE, pars) ...
                    sum(arrayfun(@(x) gauss(x, pars), [u1, u2, u3, dE]), 2);
            obj.gauss_params = [10, 0.1, 0.05];

            % Sum of multiple of each coordinate
            obj.linear_func = ...
                @(u1, u2, u3, dE, pars) sum([u1, u2, u3, dE].*pars, 2);
            obj.linear_params = [2, 1, 1, 4];

            obj.sqw_2d_obj = sqw(obj.sqw_2d_file_path);
            obj.sqw_2d_sqw_eval_ref_obj = sqw(obj.sqw_2d_sqw_eval_ref_file);
        end

        %% Argument validation tests
        function test_invalid_argument_error_if_unknown_flag_give(obj)
            f = @() sqw_eval( ...
                obj.sqw_2d_obj, obj.gauss_sqw, obj.gauss_params, '-notaflag' ...
            );
            assertExceptionThrown(f, 'HORACE:SQW_EVAL:invalid_argument');
        end

        %% SQW object tests
        function test_gauss_on_sqw_object_matches_reference_file(obj)
            out_sqw = sqw_eval(obj.sqw_2d_obj, obj.gauss_sqw, obj.gauss_params);

            assertEqualToTol( ...
                out_sqw, obj.sqw_2d_sqw_eval_ref_obj, obj.FLOAT_TOL, ...
                'ignore_str', true ...
            );
        end

        function test_gauss_on_array_of_sqw_objects_matches_reference_file(obj)
            sqws_in = [obj.sqw_2d_obj, obj.sqw_2d_obj];

            out_sqw = sqw_eval(sqws_in, obj.gauss_sqw, obj.gauss_params);

            assertEqual(size(out_sqw), size(sqws_in));
            for i = 1:numel(sqws_in)
                assertEqualToTol( ...
                    out_sqw(i), obj.sqw_2d_sqw_eval_ref_obj, obj.FLOAT_TOL, ...
                    'ignore_str', true ...
                );
            end
        end

        %% SQW file tests
        function test_gauss_on_sqw_file_matches_reference_file(obj)
            out_sqw = sqw_eval(obj.sqw_2d_file_path, obj.gauss_sqw, obj.gauss_params);

            assertEqualToTol( ...
                out_sqw, obj.sqw_2d_sqw_eval_ref_obj, obj.FLOAT_TOL, ...
                'ignore_str', true ...
            );
        end

        function test_gauss_on_cell_of_sqw_files_matches_reference_file(obj)
            sqws_in = {obj.sqw_2d_file_path, obj.sqw_2d_file_path};

            out_sqw = sqw_eval(sqws_in, obj.gauss_sqw, obj.gauss_params);

            assertEqual(size(out_sqw), size(sqws_in));
            for i = 1:numel(sqws_in)
                assertEqualToTol( ...
                    out_sqw(i), obj.sqw_2d_sqw_eval_ref_obj, obj.FLOAT_TOL, ...
                    'ignore_str', true ...
                );
            end
        end

        %% DND tests
        function test_func_on_dnd_file_acts_on_signal_and_sets_e_to_zeros(obj)
            fake_dnd = obj.build_fake_dnd();

            dnd_out = sqw_eval(fake_dnd, obj.linear_func, obj.linear_params);

            % Expected signal is bin_centers.*pars
            % bin center coords in each dim are {[1, 2, 3], [], [0.6, 1], []}
            % These are defined by dnd.p (the bin edges), which was set when
            % creating the dnd.
            % => bin centers are:
            %     [1, 0.6], [3, 0.6], [2, 1],
            %     [2, 0.6], [1,   1], [3, 1]
            % pars = [2, 1, 1, 4]
            % => since dnd.pax = [1, 3], only relevant pars are at idx 1 and 3
            % => pars = [2, 1]
            % => signal =
            %     sum([1, 0.6]*[2, 1]), sum([3, 0.6]*[2, 1]), sum([2, 1]*[2, 1]),
            %     sum([2, 0.6]*[2, 1]), sum([1,   1]*[2, 1]), sum([3, 1]*[2, 1])
            % but empty bins are ignored, so set [1, 2] to 0
            expected_signal = [ ...
                2.6, 0.0, 5.0;
                4.6, 3.0, 7.0 ...
            ];

            assertEqualToTol(dnd_out.s, expected_signal, 1e-8);
            assertEqual(dnd_out.e, zeros(size(fake_dnd.npix)));
        end

        function test_func_on_dnd_file_acts_on_non_empty_bins_if_all_flag_true(obj)
            fake_dnd = obj.build_fake_dnd();

            dnd_out = sqw_eval(fake_dnd, obj.linear_func, obj.linear_params, 'all');

            expected_signal = [ ...
                2.6, 6.6, 5.0;
                4.6, 3.0, 7.0 ...
            ];
            assertEqualToTol(dnd_out.s, expected_signal, 1e-8);
            assertEqual(dnd_out.e, zeros(size(fake_dnd.npix)));
        end
    end

    methods (Static)
        function fake_dnd = build_fake_dnd()
            fake_dnd = d2d();
            fake_dnd.s = [1, 0, 2;  7, 1, 2];
            fake_dnd.npix = [2, 0, 6;  8, 3, 4];
            fake_dnd.e = sqrt(fake_dnd.s)./fake_dnd.npix;
            fake_dnd.p = {linspace(0.5, 3.5, 4), linspace(0.4, 1.2, 3)};
            fake_dnd.pax = [1, 3];
        end
    end
end
