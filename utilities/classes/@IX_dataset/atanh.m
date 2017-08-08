function w = atanh (w1)
% Implement atanh(w1) for objects
%
%   >> w = atanh(w1)
%

w = IX_dataset.unary_op_manager (w1, @atanh_single);
