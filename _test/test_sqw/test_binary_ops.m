classdef test_binary_ops < TestCase
%% TEST_BINARY_OPS tests for behaviour of binary operations between SQW and
% and other type of objects e.g. scalars, dnd and other SQW objects
%
properties (Constant)
    DOUBLE_REL_TOLERANCE = 10e-6;
end

properties
    test_sqw_file_path = '../test_sqw_file/sqw_2d_1.sqw';
    base_sqw_obj;
    sqw_obj;
    dnd_obj;
end

methods

    function obj = test_binary_ops(varargin)
        obj = obj@TestCase('test_binary_ops');

        obj.base_sqw_obj = sqw(obj.test_sqw_file_path);
    end

    function obj = setUp(obj)
        obj.sqw_obj = copy(obj.base_sqw_obj);
        obj.dnd_obj = d2d(obj.base_sqw_obj);
    end

    function test_SQW_error_if_first_input_is_int64(obj)
        f = @() int64(ones(size(obj.sqw_obj.data.npix))) + obj.sqw_obj;
        assertExceptionThrown(f, 'SQW:binary_op_manager_single');
    end

    function test_SQW_error_if_first_input_is_char(obj)
        f = @() 'some char' + obj.sqw_obj;
        assertExceptionThrown(f, 'SQW:binary_op_manager_single');
    end

    function test_SQW_error_if_second_input_not_supported_type(obj)
        f = @() obj.sqw_obj + int64(ones(size(obj.sqw_obj.data.npix)));
        assertExceptionThrown(f, 'SQW:binary_op_manager_single');
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

    function test_subtracting_sqw_from_dnd_returns_sqw_equal_image_data(obj)
        out = obj.dnd_obj - obj.sqw_obj;

        assertTrue(isa(out, 'sqw'));

        % Scale the difference to account for floating point errors
        scaled_diff = out.data.s./max(obj.dnd_obj.s, obj.sqw_obj.data.s);
        scaled_diff(isnan(scaled_diff)) = 0;

        expected_signal = zeros(size(obj.sqw_obj.data.s));
        assertElementsAlmostEqual(scaled_diff, expected_signal, 'absolute', ...
                                  1e-7);
    end

    function test_subtracting_dnd_from_sqw_returns_sqw_equal_image_data(obj)
        out = obj.sqw_obj - obj.dnd_obj;

        assertTrue(isa(out, 'sqw'));

        % Scale the difference to account for floating point errors
        scaled_diff = out.data.s./max(obj.dnd_obj.s, obj.sqw_obj.data.s);
        scaled_diff(isnan(scaled_diff)) = 0;

        expected_signal = zeros(size(obj.sqw_obj.data.s));
        assertElementsAlmostEqual(scaled_diff, expected_signal, 'absolute', ...
                                  1e-7);
    end

    function test_subtracting_dnd_from_sqw_returns_sqw_non_equal_image_data(obj)
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

    function test_adding_sqw_and_sigvar_with_sqw_2nd_operand_returns_sigvar(obj)
        signal = 1e5 * (1 + rand(size(obj.sqw_obj.data.s)));
        variance = 1e5 * (1 + rand(size(obj.sqw_obj.data.s)));
        out = sigvar(signal, variance) + obj.sqw_obj;

        assertTrue(isa(out, 'sigvar'));

        expected_sigvar = sigvar(obj.sqw_obj.data.s + signal, ...
                                 obj.sqw_obj.data.e + variance);
        assertElementsAlmostEqual(out.s, expected_sigvar.s, 'relative', ...
                                  obj.DOUBLE_REL_TOLERANCE);
        assertElementsAlmostEqual(out.e, expected_sigvar.e, 'relative', ...
                                  obj.DOUBLE_REL_TOLERANCE);
    end

end

end
