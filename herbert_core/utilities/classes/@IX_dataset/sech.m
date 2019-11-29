function w = sech (w1)
% Implement sech(w1) for objects
%
%   >> w = sech(w1)
%

w = IX_dataset.unary_op_manager (w1, @sech_single);
