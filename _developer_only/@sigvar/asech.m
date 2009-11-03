function w = asech (w1)
% Implement asech(w1) for objects
%
%   >> w = asech(w1)
%

w = unary_op_manager (w1, @asech_single);
