classdef(Abstract) data_op_interface
    %DATA_OP_INTERFACE defines the operations, which are available on
    % numeric, sigvar, IX_data, DnD and SQW objects.
    %
    % The operations are implemented using unary and binary operation
    % managers.
    properties(Constant,Access = private)
        % list of classes which have binary operations redefined.
        base_classes   = {'sqw','PixelDataBase','DnDBase','IX_dataset','sigvar','numeric'};
        % Base priorities of the base_classes used to determine the type of
        % result of binary operations. The actual priority is calculated
        % from the base priority by adding points for presence of pixels
        % (+100) and image (+10) giving final score (priority) for an object.
        % If binary operation is performed between operands with different
        % priorities, the result has the type of the higher priority object.
        bc_priority =       [ 5,              4,        3,          2,        1,  0];
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
        w = binary_op_manager_single(w1, w2, op_function_handle);
    end
    methods(Static)
        function [priority,sv_size,has_pix,has_img] = get_priority(obj)
            % function returns a class priority which defines operations
            % order.
            %
            % Input:
            % obj   -- the object to check
            % Outuput:
            % priority  -- the number, which defines the priority of this
            %              object operation within the list of all
            %              operations
            % sv_size   -- sigvar size of the object (size of its image)
            % has_pix   -- true if object conains pixels
            % has_img   -- true if the object is not a scalar (has image)
            %
            [priority,sv_size,has_pix,has_img] = get_priority_(obj);
        end
        function op_kind = get_operation_kind(op1_has_pix,op1_has_img,op2_has_pix,op2_has_img)
            % What kind of operation should be applied between two operands
            % given operand features.
            % There are 5 types of operations:
            % 1 -> object<->scalar 2-> object<->image and 3->object<->object
            % 0 means operations can be performed by converting to sigvar.
            % Inputs:
            % op1_has_pix   -- true if operand 1 has pixels
            % op1_has_img   -- true if operand 1 has image
            % op2_has_pix   -- true if operand 2 has pixels
            % op2_has_img   -- true if operand 2 has image
            % Returns:
            % number from 0 to 3, describing type of operation, performed
            % over pixels
            op_kind = get_operation_kind_(op1_has_pix,op1_has_img,op2_has_pix,op2_has_img);
            %
        end
        function [flip,page_op_kind] = get_operation_order(obj1,obj2,op_name)
            % Helper function to establish order of operands in binary
            % operations.
            % Input:
            % obj1  -- the object provided as first term of the operation
            % obj2  -- the object provided as second tern of the operation
            % op_name
            %       -- string containing the operation name. Used in error
            %          reporting.
            % Returns:
            % flip  -- true if class 2 is superior over class 1 and binary
            %          operations should return class 2 as the result of
            %          operation instead of class1 as it would normally
            %          occur.
            % page_op_kind
            %       -- depending on operands, 4 types of page op are
            %          defined. See get_operation_kind for the details of the
            %          operations kinds.
            %
            if nargin<3
                op_name = 'an_operation';
            end
            [flip,page_op_kind] = is_superior_(obj1,obj2,op_name);
        end
    end
    methods(Access=protected)
        w = binary_op_manager(w1,w2,op_function_handle);
        w = unary_op_manager (w1, op_function_handle);
    end

end