function w = sec_single (w1)
% sec function for signal and variance

s = sec(w1.signal_);
if ~isempty(w1.variance_)
    e = abs(s.^2-1).*(s.^2).*w1.variance_;     % ensure positive
else
    e = [];
end

w = sigvar2(s,e);
