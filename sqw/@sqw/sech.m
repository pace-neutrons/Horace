function w = sech (w1)
% Implement sech(w1) for objects
%
%   >> w = sech(w1)
%

w = unary_op_manager (w1, @sech_single);
