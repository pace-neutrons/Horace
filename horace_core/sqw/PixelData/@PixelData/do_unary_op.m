function obj = do_unary_op(obj, unary_op)
% Perform a unary operation on this object's signal and variance arrays
%
% Input:
% -----
% unary_op   Function handle pointing to the operation to perform. This
%            operation should take a sigvar object as an argument.
%
obj.move_to_first_page();
while true
    pg_result = unary_op(sigvar(obj.signal, obj.variance));
    obj.signal = pg_result.s;
    obj.variance = pg_result.e;

    if obj.has_more()
        obj = obj.advance();
    else
        break;
    end
end
