function w = cos (w1)
% Implement cos(w1) for objects
%
%   >> w = cos(w1)
%

w = IX_dataset.unary_op_manager (w1, @cos_single);
