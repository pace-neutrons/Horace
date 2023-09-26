function sig_var = sigvar_binary_op_(sigvar1, sigvar2, binary_op, flip)
%% SIGVAR_BINARY_OP_ perform the given binary operation on two sigvar objects or
% between a sigvar object and a double scalar or array
%
if flip
    result = binary_op(sigvar2, sigvar1);
else
    result = binary_op(sigvar1, sigvar2);
end
sig_var = result.sig_var;
