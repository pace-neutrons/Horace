classdef(Abstract) data_op_interface
    %DATA_OP_INTERFACE defines the operations, which are available on
    % sigvar, IX_data, DnD and SQW objects
    %
    % The operations should be implemented using unary and binary operation
    % managers
    properties(Constant)
        % list of classes, participating in binary operations
        % if binary operation occurs between two classes in the list,
        % the operation returns the class, which is from the left
        super_list = {'sqw','PixelDataBase','DnDBase','IX_dataset','sigvar','numeric'}
        % if page_op selected,  three types of page_op are allowed namely
        % 1 -> object<->scalar 2-> object<->image and 3->object<->object
        % 0 means operations can be performed by converting to  sigvar.
        second_operand_type = ...
            [            3,              3,        2,            2,       2,        1]
        % force_flip property used to establish odder of binary operations.
        % If pair of classes above appears in an operation, and the number
        % of force_flip for one class is higher then the number of the
        % force_flip of another class, the class with larger number have
        % always go first in operation. This is to support the same
        % behaviour of binary operations when calling binary operation
        % function, as Matlab provides using InferiorClasses metalist
        % using operations in MATLAB row
        force_flip = [   2,              1,        0,            0,      0 ,       0]
        %
    end
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
        wout = mpower  (w1,w2)
        wout = mrdivide(w1,w2)
        wout = mtimes  (w1,w2)
        wout = plus    (w1,w2)
        %------------------------------------------------------------------
    end
    methods(Static)
        function [is,do_page_op,page_op_kind] = is_superior(obj1,obj2)
            % Helper function to establish order of operands in binary
            % operations.
            % is  -- true if class 2 is superior over class 1 and binary operations
            %        should return class 2 as the result of operation instead of
            %        class1 as it would normally occurs
            % do_page_op
            %     -- true if normal algorithm of performing operations
            %        defined by sigvar.binary_op_manager is not working and
            %        page_op-type algorithm should be used to perfrom operations.
            % page_op_kind
            %     -- depending on operands, three types of page op are
            %        allowed namely object<->scalar object<->image and object<->object
            %        0 means operations can be performed by converting to
            %        sigvar.
            %
            [is,do_page_op,page_op_kind] = is_superior_(obj1,obj2);
        end
    end
    methods(Access=protected)
        w = binary_op_manager(w1,w2,op_function_handle);
        w = binary_op_manager_single(w1, w2, op_function_handle);
        w = unary_op_manager (w1, op_function_handle);
    end

end