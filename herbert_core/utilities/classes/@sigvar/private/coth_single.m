function w = coth_single (w1)
% coth function for signal and variance

s = coth(w1.signal_);
if ~isempty(w1.variance_)
    e = ((1-s.^2).^2).*w1.variance_;
else
    e = [];
end

w = sigvar2(s,e);
