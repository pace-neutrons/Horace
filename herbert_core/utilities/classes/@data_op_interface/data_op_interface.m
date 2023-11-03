classdef(Abstract) data_op_interface
    %DATA_OP_INTERFACE defines the operations, which are available on
    % numeric, sigvar, IX_data, DnD and SQW objects.
    %
    % The operations are implemented using unary and binary operation
    % managers.
    properties(Constant,Access = private)
        % list of classes which have binary operations redefined.
        base_classes   = {'sqw','PixelDataBase','DnDBase','IX_dataset','sigvar','numeric'};
        % priorities of the base_classes. The actual priorities are
        % modified by presence of pixels and image, which increases
        % priorites. If binary operation is performed between objects
        % of operands with different priorities, the result has the type of
        % the higher priority object.
        bc_priority =       [ 5,    4,            3         ,   2     ,      1 , 0];
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
        function [priority,sv_size,has_pix,has_img] = get_priority(obj)
            % function returns a class priority which defines operations.
            %
            % All basic classes have basic priorities.
            base_num = cellfun(@(x)isa(obj,x),data_op_interface.base_classes);
            if ~any(base_num)
                error('HORACE:data_op_interface:invalid_argument', ...
                    'Class %s does not have Horace binary operation defined for it.', ...
                    class(obj));
            end
            % basic class priority
            priority = data_op_interface.bc_priority(base_num);
            sv_size   = sigvar_size(obj);
            if ~isequal(sv_size,[1,1]) % then sigvar size > 1 and this is image
                priority = priority+10;
                has_img = true;
            else
                has_img = false;
            end
            if isa(obj,'sqw') && obj.has_pixels() || isa(obj,'PixelDataBase')
                has_pix = true;
                priority = priority + 100;
                if isa(obj,'PixelDataBase')
                    priority = priority-10;
                    has_img = false;
                end
            else
                has_pix = false;
            end
        end
        function op_kind = get_operation_kind(op1_has_pix,op1_has_img,op2_has_pix,op2_has_img)
            % What kind of operation should be applied between two operands
            % given operand features.
            % There are 5 types of operations:
            % 1 -> object<->scalar 2-> object<->image and 3->object<->object
            % 0 means operations can be performed by converting to sigvar.
            % -1 means operation prohibited (or will not be performed)
            if op1_has_pix
                if op2_has_pix
                    op_kind = 3;
                elseif op2_has_img
                    op_kind = 2;
                else
                    op_kind = 1;
                end
            elseif op1_has_img
                % op2 can not have pixels,it will be the first operator in
                % this case
                op_kind = 0;
            else
                op_kind = -1;
            end
            %
        end
        function [flip,page_op_kind] = get_op_kind(obj1,obj2,op_name)
            % Helper function to establish order of operands in binary
            % operations.
            % Input:
            % obj1  -- the object provided as first term of the operation
            % obj2  -- the object provided as second tern of the operation
            % op_nam -- string containing the operation name. Used in error
            %          reporting
            % Returns:
            % flip  -- true if class 2 is superior over class 1 and binary
            %          operations should return class 2 as the result of
            %          operation instead of class1 as it would normally
            %          occur.
            % page_op_kind
            %       -- depending on operands, 5 types of page op are
            %          defined. See get_op_kind for the details of the
            %          operations.
            %
            [flip,page_op_kind] = is_superior_(obj1,obj2,op_name);
        end
    end
    methods(Access=protected)
        w = binary_op_manager(w1,w2,op_function_handle);
        w = binary_op_manager_single(w1, w2, op_function_handle);
        w = unary_op_manager (w1, op_function_handle);
    end

end