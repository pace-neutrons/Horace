function w = cos_single (w1)
% cos function for signal and variance

s = cos(w1.signal_);
if ~isempty(w1.variance_)
    e = abs(1-s.^2).*w1.variance_;     % ensure positive
else
    e = [];
end

w = sigvar2(s,e);
