function w = csc (w1)
% Implement csc(w1) for objects
%
%   >> w = csc(w1)
%

w = IX_dataset.unary_op_manager (w1, @csc_single);
