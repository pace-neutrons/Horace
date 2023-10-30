classdef(Abstract) data_op_interface
    %DATA_OP_INTERFACE defines the operations, which are available on
    % sigvar, IX_data, DnD and SQW objects
    %
    % The operations should be implemented using unary and binary operation
    % managers
    methods
        %------------------------------------------------------------------
        % Unary operations
        wout = acos  (win)
        wout = acosh (win)
        wout = acot  (win)
        wout = acoth (win)
        wout = acsc  (win)
        wout = acsch (win)
        wout = asec  (win)
        wout = asech (win)
        wout = asin  (win)
        wout = asinh (win)
        wout = atan  (win)
        wout = atanh (win)
        wout = cos   (win)
        wout = cosh  (win)
        wout = cot   (win)
        wout = coth  (win)
        wout = csc   (win)
        wout = csch  (win)
        wout = exp   (win)
        wout = log   (win)
        wout = log10 (win)
        wout = mpower(win)
        wout = sec   (win)
        wout = sech  (win)
        wout = sin   (win)
        wout = sinh  (win)
        wout = sqrt  (win)
        wout = tan   (win)
        wout = tanh  (win)
        wout = uminus(win)
        wout = uplus (win)
        %------------------------------------------------------------------
        % binary operations
        wout = minus   (w1,w2)
        wout = mldivide(w1,w2)
        wout = mrdivide(w1,w2)
        wout = mtimes  (w1,w2)
        wout = plus    (w1,w2)
    end
    methods(Access=protected)
        w = binary_op_manager(w1,w2,op_function_handle);
        w = binary_op_manager_single(w1, w2, op_function_handle);
        w = unary_op_manager (w1, op_function_handle);        
    end
end