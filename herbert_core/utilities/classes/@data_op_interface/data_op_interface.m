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
        super_list = {'sqw','DnDBase','IX_dataset','sigvar'}
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
        %------------------------------------------------------------------
    end
    methods(Static)
        function is = is_superior(obj1,obj2)
            % found if class 1 is superior over class 2 and we would prefer
            % return class 1 as the result of operation.
            if isnumeric(obj1) && ~isnumeric(obj2)
                is = false;
                return;
            end
            if isnumeric(obj2) && ~isnumeric(obj1)
                is = true;
                return;
            end
            classname1 = class(obj1);
            classname2 = class(obj2);
            if strcmp(classname1,classname2)
                is = true;
                return;
            end
            is_1 = cellfun(@(x)isa(obj1,x),data_op_interface.super_list);
            is_2 = cellfun(@(x)isa(obj2,x),data_op_interface.super_list);
            pos1 = find(is_1);
            pos2 = find(is_2);
            if pos1<pos2
                is = true;
            else
                is = false;
            end
        end
    end
    methods(Access=protected)
        w = binary_op_manager(w1,w2,op_function_handle);
        w = binary_op_manager_single(w1, w2, op_function_handle);
        w = unary_op_manager (w1, op_function_handle);
    end

end