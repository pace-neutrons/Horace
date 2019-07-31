function w = atan (w1)
% Implement atan(w1) for objects
%
%   >> w = atan(w1)
%

w = IX_dataset.unary_op_manager (w1, @atan_single);
