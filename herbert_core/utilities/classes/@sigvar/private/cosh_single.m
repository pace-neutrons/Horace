function w = cosh_single (w1)
% cosh function for signal and variance

s = cosh(w1.signal_);
if ~isempty(w1.variance_)
    e = abs(s.^2-1).*w1.variance_;     % ensure positive
else
    e = [];
end

w = sigvar(s,e);
