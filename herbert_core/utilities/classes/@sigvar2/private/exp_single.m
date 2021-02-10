function w = exp_single (w1)
% exp function for signal and variance

s = exp(w1.signal_);
if ~isempty(w1.variance_)
    e = (s.^2).*w1.variance_;
else
    e = [];
end

w = sigvar2(s,e);
