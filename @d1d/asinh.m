function w = asinh (w1)
% Implement asinh(w1) for objects
%
%   >> w = asinh(w1)
%

w = unary_op_manager (w1, @asinh_single);
