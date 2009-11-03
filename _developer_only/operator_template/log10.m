function w = log10 (w1)
% Implement log(w1) for objects
%
%   >> w = log(w1)
%

w = unary_op_manager (w1, @log10_single);
