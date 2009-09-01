function w = csch (w1)
% Implement csch(w1) for objects
%
%   >> w = csch(w1)
%

w = unary_op_manager (w1, @csch_single);
