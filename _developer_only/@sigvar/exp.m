function w = exp (w1)
% Implement exp(w1) for objects
%
%   >> w = exp(w1)
%

w = unary_op_manager (w1, @exp_single);
