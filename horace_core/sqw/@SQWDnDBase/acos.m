function w = acos (w1)
% Implement acos(w1) for objects
%
%   >> w = acos(w1)
%

w = unary_op_manager (w1, @acos_single);
