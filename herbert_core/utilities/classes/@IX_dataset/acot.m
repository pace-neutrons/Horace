function w = acot (w1)
% Implement acot(w1) for objects
%
%   >> w = acot(w1)
%

w = IX_dataset.unary_op_manager (w1, @acot_single);
