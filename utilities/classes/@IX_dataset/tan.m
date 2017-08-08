function w = tan (w1)
% Implement tan(w1) for objects
%
%   >> w = tan(w1)
%

w = IX_dataset.unary_op_manager (w1, @tan_single);
