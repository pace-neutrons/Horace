function w = asec (w1)
% Implement asec(w1) for objects
%
%   >> w = asec(w1)
%

w = unary_op_manager (w1, @asec_single);
