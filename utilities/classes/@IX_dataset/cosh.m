function w = cosh (w1)
% Implement cosh(w1) for objects
%
%   >> w = cosh(w1)
%

w = IX_dataset.unary_op_manager (w1, @cosh_single);
