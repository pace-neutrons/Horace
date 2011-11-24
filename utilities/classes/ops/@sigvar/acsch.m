function w = acsch (w1)
% Implement acsch(w1) for objects
%
%   >> w = acsch(w1)
%

w = unary_op_manager (w1, @acsch_single);
