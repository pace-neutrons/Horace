function w = asin (w1)
% Implement asin(w1) for objects
%
%   >> w = asin(w1)
%

w = unary_op_manager (w1, @asin_single);
