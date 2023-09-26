function obj = binary_op_scalar_(obj, scalar, binary_op, flip)
%% DO_BINARY_OP_SCALAR_ perform the given binary operation between a
% PixelData object and scalar.
%

pix_sigvar = sigvar(obj.signal, obj.variance);
scalar_sigvar = scalar;     % TGP 2021-04-11: to work with new classdef sigvar

res = ...
    obj.sigvar_binary_op(pix_sigvar, scalar_sigvar, binary_op, flip);
obj.signal = res(1,:);
obj.variance = res(2,:);