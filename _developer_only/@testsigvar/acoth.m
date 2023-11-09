function w = acoth (w1)
% Implement acoth(w1) for objects
%
%   >> w = acoth(w1)
%

w = unary_op_manager (w1, @acoth_single);
