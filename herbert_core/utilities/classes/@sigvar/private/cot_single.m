function w = cot_single (w1)
% cot function for signal and variance

s = cot(w1.signal_);
if ~isempty(w1.variance_)
    e = ((1+s.^2).^2).*w1.variance_;
else
    e = [];
end

w = sigvar(s,e);
