function w = sinh (w1)
% Implement sinh(w1) for objects
%
%   >> w = sinh(w1)
%

w = IX_dataset.unary_op_manager (w1, @sinh_single);
