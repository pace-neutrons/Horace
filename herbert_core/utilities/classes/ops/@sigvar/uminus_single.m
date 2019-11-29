function w = uminus_single (w1)
% Unary minus

w.s = -w1.s;
w.e = w1.e;

w = class(w,'sigvar');
