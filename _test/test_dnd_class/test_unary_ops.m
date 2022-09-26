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
            ab = axes_block([-0.1,0.1],[-2,2],[0,1],[-2,2]);                                                
            dnd_obj = d0d(ab,ortho_proj());
            obj.assert_allfunctions_defined(dnd_obj);
        end
        function test_all_functions_are_defined_in_1d(obj)
            ab = axes_block([-0.1,0.1],[-2,2],[0,1],[-2,0.05,2]);                                    
            dnd_obj = d1d(ab,ortho_proj());
            obj.assert_allfunctions_defined(dnd_obj);
        end
        function test_all_functions_are_defined_in_2d(obj)
            ab = axes_block([-0.1,0.01,0.1],[-2,2],[0,1],[-2,0.05,2]);                        
            dnd_obj = d2d(ab,ortho_proj());
            obj.assert_allfunctions_defined(dnd_obj);
        end
        function test_all_functions_are_defined_in_3d(obj)
            ab = axes_block([-0.1,0.01,0.1],[-2,2],[0,0.1,1],[-2,0.05,2]);            
            dnd_obj = d3d(ab,ortho_proj());
            obj.assert_allfunctions_defined(dnd_obj);
        end
        function test_all_functions_are_defined_in_4d(obj)
            ab = axes_block([-0.1,0.01,0.1],[-2,0.05,2],[0,0.1,1],[-2,0.05,2]);
            dnd_obj = d4d(ab,ortho_proj());
            obj.assert_allfunctions_defined(dnd_obj);
        end
        
        function assert_allfunctions_defined(obj, dnd_obj)
            
            % For each unary operator, perform the operation on some random data
            % generated with the valid range for that function input
            for i = 1:2:numel(obj.unary_ops)
                unary_op = obj.unary_ops{i};
                data_range = obj.unary_ops{i+1};
                
                test_obj = copy(dnd_obj);
                sz = dnd_obj.axes.dims_as_ssize();
                test_obj.s = test_unary_ops.get_rnd_data_in_range(sz, data_range);
                test_obj.e = test_unary_ops.get_rnd_data_in_range(sz, data_range);
                
                % exception will be thrown if method not implemented
                result = unary_op(test_obj);
                
                % confirm the data (s, e) has been updated
                assertFalse(equal_to_tol(result.s, test_obj.s));
                assertFalse(equal_to_tol(result.e, test_obj.e));
            end
        end
        
        function test_unary_op_updates_image_signal_and_error(~)
            ax = axes_block('nbins_all_dims',[2,1,1,1]);
            pr = ortho_proj();
            dnd_obj = d1d(ax,pr,[2, 10245],[1.5, 1021],[1,1]);
            
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
    methods(Static)
        function data=get_rnd_data_in_range(size_vec, data_range)
            data = data_range(1) + (data_range(2) - data_range(1)).*rand(size_vec);            
        end
        
    end
end
