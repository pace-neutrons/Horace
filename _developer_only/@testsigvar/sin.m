function w = sin (w1)
% Implement sin(w1) for objects
%
%   >> w = sin(w1)
%

w = unary_op_manager (w1, @sin_single);
