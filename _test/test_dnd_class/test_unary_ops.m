classdef test_unary_ops < TestCase
    
    properties
        
        % the unary operation and the range the data it acts on should take
        unary_ops = {
            @acos, [0, 1], ...
            @acosh, [1, 3], ...
            @acot, [0, 1], ...
            @acoth, [10, 15], ...
            @acsc, [1, 3], ...
            @acsch, [1, 3], ...
            @asec, [1.5, 3], ...
            @asech, [0, 1], ...
            @asin, [0, 1], ...
            @asinh, [1, 3], ...
            @atan, [0, 1], ...
            @atanh, [0, 0.5], ...
            @cos, [0, 1], ...
            @cosh, [0, 1], ...
            @cot, [0, 1], ...
            @coth, [1.5, 3], ...
            @csc, [0.5, 2.5], ...
            @csch, [1, 3], ...
            @exp, [0, 1], ...
            @log, [1, 3], ...
            @log10, [1, 3], ...
            @sec, [2, 4], ...
            @sech, [0, 1.4], ...
            @sin, [0, 3], ...
            @sinh, [0, 3], ...
            @sqrt, [0, 3], ...
            @tan, [0, 1], ...
            @tanh, [0, 3], ...
            };
        
    end
    methods
        
        function obj = test_unary_ops(~)
            obj = obj@TestCase('test_unary_ops');
        end
        
        function test_all_functions_are_defined_in_0d(obj)
            dnd_obj = d0d();
            obj.assert_allfunctions_defined(dnd_obj);
        end
        function test_all_functions_are_defined_in_1d(obj)
            dnd_obj = d1d();
            obj.assert_allfunctions_defined(dnd_obj);
        end
        function test_all_functions_are_defined_in_2d(obj)
            dnd_obj = d2d();
            obj.assert_allfunctions_defined(dnd_obj);
        end
        function test_all_functions_are_defined_in_3d(obj)
            dnd_obj = d3d();
            obj.assert_allfunctions_defined(dnd_obj);
        end
        function test_all_functions_are_defined_in_4d(obj)
            dnd_obj = d4d();
            obj.assert_allfunctions_defined(dnd_obj);
        end
        
        function assert_allfunctions_defined(obj, dnd_obj)
            
            % For each unary operator, perform the operation on some random data
            % generated with the valid range for that function input
            num_rows = 29;
            num_cols = 7;
            for i = 1:2:numel(obj.unary_ops)
                unary_op = obj.unary_ops{i};
                data_range = obj.unary_ops{i+1};
                
                test_obj = copy(dnd_obj);
                test_obj.s = get_random_data_in_range(num_rows, num_cols, data_range);
                test_obj.e = get_random_data_in_range(num_rows, num_cols, data_range);
                
                % exception will be thrown if method not implemented
                result = unary_op(test_obj);
                
                % confirm the data (s, e) has been updated
                assertFalse(equal_to_tol(result.s, test_obj.s));
                assertFalse(equal_to_tol(result.e, test_obj.e));
            end
        end
        
        function test_unary_op_updates_image_signal_and_error(~)
            dnd_obj = d2d();
            dnd_obj.s = [2, 10245]; % simple dataset for ease of testing
            dnd_obj.e = [1.5, 1021];
            dnd_obj.npix = [1,1];
            
            % arbitrary unary op for test
            result = log10(dnd_obj);
            
            % explicit calculation test
            % calculate reference values using code matching implmentation in 'log10_single'
            expected_signal = log10(dnd_obj.s);
            expected_var = dnd_obj.e./(dnd_obj.s*log(10)).^2;
            
            assertEqualToTol(result.s, expected_signal);
            assertEqualToTol(result.e, expected_var);
        end
        
    end
end
