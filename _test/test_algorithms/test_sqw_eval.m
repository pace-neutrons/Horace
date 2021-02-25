classdef test_sqw_eval < TestCase

    properties (Constant)
        FLOAT_TOL = 1e-5;
    end

    properties
        d2d_file_path = '../test_rebin/w2d_qe_d2d.sqw'

        d2d_obj;

        sqw_2d_file_path = '../test_sqw_file/sqw_2d_1.sqw';
        sqw_2d_sqw_eval_ref_file = 'test_sqw_eval_gauss_ref.sqw';

        sqw_2d_obj;
        sqw_2d_sqw_eval_ref_obj;

        gauss_sqw;
        gauss_params;
    end

    methods

        function obj = test_sqw_eval(~)
            obj = obj@TestCase('test_sqw_eval');
            % Sum of the gaussian of each coordinate
            obj.gauss_sqw = ...
                @(u1, u2, u3, dE, pars) ...
                    sum(arrayfun(@(x) gauss(x, pars), [u1, u2, u3, dE]), 2);
            obj.gauss_params = [10, 0.1, 0.05];

            obj.d2d_obj = d2d(obj.d2d_file_path);
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
    end
end
