function w = sec (w1)
% Implement sec(w1) for objects
%
%   >> w = sec(w1)
%

w = unary_op_manager (w1, @sec_single);
