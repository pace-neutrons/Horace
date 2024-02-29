classdef test_binary_ops < TestCase
    %% TEST_BINARY_OPS tests for behaviour of binary operations between SQW and
    % and other type of objects e.g. scalars, dnd and other SQW objects
    %
    properties (Constant)
        DOUBLE_REL_TOLERANCE = 10e-6;
    end

    properties
        test_sqw_file_path = '../common_data/sqw_2d_1.sqw';
        base_sqw_obj;
        sqw_obj;
        dnd_obj;
    end

    methods

        function obj = test_binary_ops(varargin)
            obj = obj@TestCase('test_binary_ops');

            s0 = sqw(obj.test_sqw_file_path);
            % s0 contains invalid ratio between pixels and image!
            obj.base_sqw_obj = recompute_bin_data(s0);
        end

        function obj = setUp(obj)
            obj.sqw_obj = copy(obj.base_sqw_obj);
            obj.dnd_obj = d2d(obj.base_sqw_obj);
        end

        function test_SQW_error_if_operand_is_char(obj)
            f = @() 'some char' + obj.sqw_obj;
            ff = @()  obj.sqw_obj + 'some char';
            assertExceptionThrown(f, 'HERBERT:data_op_interface:invalid_argument');
            assertExceptionThrown(ff, 'HERBERT:data_op_interface:invalid_argument');
        end

        function test_SQW_error_if_operand_is_cell_array(obj)
            f = @() {1, 2, 3} + obj.sqw_obj;
            ff = @() obj.sqw_obj + {0};
            assertExceptionThrown(f, 'HERBERT:data_op_interface:invalid_argument');
            assertExceptionThrown(ff,'HERBERT:data_op_interface:invalid_argument');
        end

        function test_SQW_error_if_operand_is_non_numeric(obj)
            unsupported_types = {@logical};

            for i = 1:numel(unsupported_types)
                type_func = unsupported_types{i};
                numeric_array = type_func(ones(size(obj.sqw_obj.data.npix)));
                f = @() obj.sqw_obj + numeric_array;
                ff = @() numeric_array + obj.sqw_obj;
                assertExceptionThrown(f, 'HERBERT:data_op_interface:invalid_argument');
                assertExceptionThrown(ff, 'HERBERT:data_op_interface:invalid_argument');
            end
        end

        function test_SQW_works_if_both_objects_are_sqw_with_no_pixel_data(obj)
            obj.sqw_obj.pix = PixelDataBase.create();

            res =  obj.sqw_obj - obj.sqw_obj;
            assertTrue(isa(res,'sqw'));
            assertElementsAlmostEqual(res.data.s,zeros(size(res.data.s)));
        end
        
        function test_subtracting_dnd_from_sqw(obj)
            res = obj.sqw_obj-obj.dnd_obj;

            sz = size(res.data.s);
            assertEqualToTol(res.data.s,zeros(sz),1.e-9);
            test_obj = recompute_bin_data(res);
            assertEqualToTol(res,test_obj,1.e-9);

            % Errors are accumulated in operations, not extracted, so 
            % reverse operation reverses signal but increases the errors
            rec = obj.dnd_obj + res;
            assertEqualToTol(rec.data.s,obj.sqw_obj.data.s,1.e-9);
            assertEqualToTol(rec.pix.signal,obj.sqw_obj.pix.signal,1.e-9);            
        end

        function test_adding_sqw_and_dnd_objects_1st_operand_is_sqw_returns_sqw(obj)
            out = obj.sqw_obj + obj.dnd_obj;

            assertTrue(isa(out, 'sqw'));

            expected_signal = obj.sqw_obj.data.s + obj.dnd_obj.s;
            assertElementsAlmostEqual(out.data.s, expected_signal, 'relative', ...
                obj.DOUBLE_REL_TOLERANCE);
        end

        function test_adding_sqw_and_dnd_objects_2nd_operand_is_sqw_returns_sqw(obj)
            out = obj.dnd_obj + obj.sqw_obj;

            assertTrue(isa(out, 'sqw'));

            expected_signal = obj.sqw_obj.data.s + obj.dnd_obj.s;
            assertElementsAlmostEqual(out.data.s, expected_signal, 'relative', ...
                obj.DOUBLE_REL_TOLERANCE);
        end

        function test_dnd_minus_equivalent_sqw_returns_sqw_with_zero_image_data(obj)
            out = obj.dnd_obj - obj.sqw_obj;

            assertTrue(isa(out, 'sqw'));

            % Scale the difference to account for floating point errors
            scaled_diff = out.data.s./max(obj.dnd_obj.s, obj.sqw_obj.data.s);
            scaled_diff(isnan(scaled_diff)) = 0;

            expected_signal = zeros(size(obj.sqw_obj.data.s));
            assertElementsAlmostEqual(scaled_diff, expected_signal, 'absolute', ...
                1e-7);
        end

        function test_sqw_minus_equivalent_dnd_returns_sqw_with_zero_image_data(obj)
            out = obj.sqw_obj - obj.dnd_obj;

            assertTrue(isa(out, 'sqw'));

            % Scale the difference to account for floating point errors
            scaled_diff = out.data.s./max(obj.dnd_obj.s, obj.sqw_obj.data.s);
            scaled_diff(isnan(scaled_diff)) = 0;

            expected_signal = zeros(size(obj.sqw_obj.data.s));
            assertElementsAlmostEqual(scaled_diff, expected_signal, 'absolute', ...
                1e-7);
        end

        function test_subtracting_dnd_from_sqw_returns_sqw(obj)
            obj.dnd_obj.s = ones(size(obj.dnd_obj.npix));
            out = obj.sqw_obj - obj.dnd_obj;

            assertTrue(isa(out, 'sqw'));

            expected_signal = obj.sqw_obj.data.s - 1;
            expected_signal(obj.sqw_obj.data.npix == 0) = 0;
            assertElementsAlmostEqual(out.data.s, expected_signal, 'relative', ...
                obj.DOUBLE_REL_TOLERANCE);
        end

        function test_subtracting_scalar_from_sqw_returns_sqw(obj)
            scalar_operand = 1.3;
            out = obj.sqw_obj - scalar_operand;

            assertTrue(isa(out, 'sqw'));

            expected_signal = obj.sqw_obj.data.s - scalar_operand;
            expected_signal(obj.sqw_obj.data.npix == 0) = 0;
            assertElementsAlmostEqual(out.data.s, expected_signal, 'relative', ...
                obj.DOUBLE_REL_TOLERANCE);
        end

        function test_subtracting_sqw_from_scalar_returns_sqw(obj)
            scalar_operand = 0.3;
            out = scalar_operand - obj.sqw_obj;

            assertTrue(isa(out, 'sqw'));

            expected_signal = scalar_operand - obj.sqw_obj.data.s;
            expected_signal(obj.sqw_obj.data.npix == 0) = 0;
            assertElementsAlmostEqual(out.data.s, expected_signal, 'relative', ...
                obj.DOUBLE_REL_TOLERANCE);
        end

        function test_subtracting_two_sqw_objects_returns_sqw(obj)
            out = obj.sqw_obj - obj.sqw_obj;

            assertTrue(isa(out, 'sqw'));
            assertElementsAlmostEqual(out.data.s, zeros(size(out.data.s)));
        end

        function test_adding_sqw_and_sigvar_with_sqw_1st_operand_returns_sqw(obj)
            signal = 1e5 * (1 + rand(size(obj.sqw_obj.data.s)));
            variance = 1e5 * (1 + rand(size(obj.sqw_obj.data.s)));
            out = obj.sqw_obj + sigvar(signal, variance);

            assertTrue(isa(out, 'sqw'));

            expected_signal = obj.sqw_obj.data.s + signal;
            expected_signal(obj.sqw_obj.data.npix == 0) = 0;
            assertElementsAlmostEqual(out.data.s, expected_signal, 'relative', ...
                obj.DOUBLE_REL_TOLERANCE);
        end

        function test_adding_sqw_and_sigvar_with_sqw_2nd_operand_returns_sqw(obj)
            signal = (1 + rand(size(obj.sqw_obj.data.s)));
            variance =(1 + rand(size(obj.sqw_obj.data.s)));
            out = sigvar(signal, variance) + obj.sqw_obj;

            assertTrue(isa(out, 'sqw'));

            npix = obj.sqw_obj.data.npix;
            signal(npix==0) = 0;
            variance = variance./npix;
            variance(npix==0) = 0;
            expected_sigvar = sigvar(obj.sqw_obj.data.s + signal, ...
                obj.sqw_obj.data.e + variance);
            assertElementsAlmostEqual(out.data.s, expected_sigvar.s, 'relative', ...
                obj.DOUBLE_REL_TOLERANCE);
            assertElementsAlmostEqual(out.data.e, expected_sigvar.e, 'relative', ...
                obj.DOUBLE_REL_TOLERANCE);
        end

        function test_adding_sqw_and_zero_returns_same_sqw(obj)
            signal = 0;
            out = signal + obj.sqw_obj;
            assertTrue(isa(out, 'sqw'));
            assertEqualToTol(out,obj.sqw_obj);
        end
        function test_adding_sqw_and_zero_data_returns_same_sqw(obj)
            signal = zeros(size(obj.sqw_obj.data.s));
            out = signal + obj.sqw_obj;
            assertTrue(isa(out, 'sqw'));
            assertEqualToTol(out,obj.sqw_obj);
        end

        function test_adding_sqw_and_zero_sigvar_returns_same_sqw(obj)
            signal = zeros(size(obj.sqw_obj.data.s));
            variance =zeros(size(obj.sqw_obj.data.s));
            out = sigvar(signal, variance) + obj.sqw_obj;

            assertTrue(isa(out, 'sqw'));

            assertEqualToTol(out,obj.sqw_obj);
        end


    end
end
