function op_kind = get_operation_kind_(op1_has_pix,op1_has_img,op2_has_pix,op2_has_img);
% What kind of operation should be applied between two operands
% given operand features.
% There are 5 types of operations:
% 1 -> object<->scalar 2-> object<->image and 3->object<->object
% 0 means operations can be performed by converting to sigvar.
% -1 means operation prohibited (or will not be performed)
% Inputs:
% op1_has_pix   -- true if operand 1 has pixels
% op1_has_img   -- true if operand 1 has image
% op2_has_pix   -- true if operand 2 has pixels
% op2_has_img   -- true if operand 2 has image
% Returns:
% number from -1 to 3, describing type of operation, performed
% over pixesl

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
    if op2_has_pix
        error('HORACE:data_op_interface:runtime_error', ...
            'Invalid order of operations identified. Obj1 does not have pixels and obj2 has them')
    end
    % image operations are perfomed though sivgar
    op_kind = 0;
else
    % numeric operand should not be able to come herec, so it is probably scalar objects
    % of allowed types
    op_kind = 0;
end
