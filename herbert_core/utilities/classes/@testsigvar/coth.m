function w = coth (w1)
% Implement coth(w1) for objects
%
%   >> w = coth(w1)
%

w = unary_op_manager (w1, @coth);
