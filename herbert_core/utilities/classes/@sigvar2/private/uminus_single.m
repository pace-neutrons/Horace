function w = uminus_single (w1)
% Unary minus

s = -w1.signal_;
e = w1.variance_;

w = sigvar2(s,e);
