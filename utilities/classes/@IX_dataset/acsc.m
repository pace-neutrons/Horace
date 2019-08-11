function w = acsc (w1)
% Implement acsc(w1) for objects
%
%   >> w = acsc(w1)
%

w = IX_dataset.unary_op_manager (w1, @acsc_single);
