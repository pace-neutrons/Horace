function w = uminus (w1)
% Implement -w1 for objects
%
%   >> w = -w1
%

w = IX_dataset.unary_op_manager (w1, @uminus_single);
