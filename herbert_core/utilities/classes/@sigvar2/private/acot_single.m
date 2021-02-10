function w = acot_single (w1)
% acot function for signal and variance

s = acot(w1.signal_);
if ~isempty(w1.variance_)
    e = w1.variance_./((1+s.^2).^2);
else
    e = [];
end

w = sigvar2(s,e);
