function w = acosh (w1)
% Implement acosh(w1) for objects
%
%   >> w = acosh(w1)
%

w = IX_dataset.unary_op_manager (w1, @acosh_single);
