function w = acosh_single (w1)
% acosh function for signal and variance

w.s = acosh(w1.s);
if ~isempty(w1.e)
    w.e = w1.e./abs(w.s.^2-1);     % ensure positive
else
    w.e = [];
end

w = class(w,'sigvar');
