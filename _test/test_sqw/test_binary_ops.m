classdef test_binary_ops < TestCase
%% TEST_BINARY_OPS tests for behaviour of binary operations between SQW and
% and other type of objects e.g. scalars, dnd and other SQW objects
%
properties (Constant)
    DOUBLE_REL_TOLERANCE = 10e-6;
end

properties
    old_config;

    test_sqw_file_path = '../test_sqw_file/sqw_2d_1.sqw';
    base_sqw_obj;
    sqw_obj;
    dnd_obj;
end

methods

    function obj = test_binary_ops(varargin)
        obj = obj@TestCase('test_binary_ops');

        conf = hor_config();
        obj.old_config = conf.get_data_to_store();
        % Tests assume all pix fit in memory by default
        conf.pixel_page_size = 1e12;

        obj.base_sqw_obj = sqw(obj.test_sqw_file_path);
    end

    function delete(obj)
        set(hor_config, obj.old_config);
    end

    function obj = setUp(obj)
        obj.sqw_obj = copy(obj.base_sqw_obj);
        obj.dnd_obj = d2d(obj.base_sqw_obj);
    end

    function test_SQW_error_if_operand_is_char(obj)
        f = @() 'some char' + obj.sqw_obj;
        ff = @()  obj.sqw_obj + 'some char';
        assertExceptionThrown(f, 'SQW:binary_op_manager_single');
        assertExceptionThrown(ff, 'SQW:binary_op_manager_single');
    end

    function test_SQW_error_if_operand_is_cell_array(obj)
        f = @() {1, 2, 3} + obj.sqw_obj;
        ff = @() obj.sqw_obj + {0};
        assertExceptionThrown(f, 'SQW:binary_op_manager_single');
        assertExceptionThrown(ff, 'SQW:binary_op_manager_single');
    end

    function test_SQW_error_if_operand_is_numeric_but_not_double(obj)
        unsupported_types = {@single, @int8, @int16, @int32, @int64, ...
                             @uint8, @uint16, @uint32, @uint64};

        for i = 1:numel(unsupported_types)
            type_func = unsupported_types{i};
            numeric_array = type_func(ones(size(obj.sqw_obj.data.npix)));
            f = @() obj.sqw_obj + numeric_array;
            ff = @() numeric_array + obj.sqw_obj;
            assertExceptionThrown(f, 'SQW:binary_op_manager_single');
            assertExceptionThrown(ff, 'SQW:binary_op_manager_single');
        end
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
    function test_add_transformed_sqw_1D(~)
        ld = load('example_d1d.mat');
        w1 = ld.w2;
        dd_sum = w1+w1;
        
        ds_sum = sqw(w1) + sqw(w1);
        
        assertEqual(dd_sum,d1d(ds_sum));
    end
    function test_add_transformed_sqw_2D(obj)
        test_file = fullfile(fileparts(obj.test_sqw_file_path),'sqw_2d_2.sqw');
        w2 = read_dnd(test_file);


        dd_sum = w2+w2;        
        ds_sum = sqw(w2) + sqw(w2);        
        assertEqual(dd_sum,d2d(ds_sum));
    end

    

end

end
