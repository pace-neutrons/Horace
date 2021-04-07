function w = cot (w1)
% Implement cot(w1) for objects
%
%   >> w = cot(w1)
%

w = unary_op_manager (w1, @cot_single);
