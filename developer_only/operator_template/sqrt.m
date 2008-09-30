function w = sqrt (w1)
% Implement sqrt(w1) for objects
%
%   >> w = sqrt(w1)
%

w = unary_op_manager (w1, @sqrt_single);
