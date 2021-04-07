function w = acosh_single (w1)
% acosh function for signal and variance

s = acosh(w1.signal_);
if ~isempty(w1.variance_)
    e = w1.variance_./abs(s.^2-1);     % ensure positive
else
    e = [];
end

w = sigvar(s,e);
