function w = sin_single (w1)
% sin function for signal and variance

s = sin(w1.signal_);
if ~isempty(w1.variance_)
    e = abs(1-s.^2).*w1.variance_;     % ensure positive
else
    e = [];
end

w = sigvar2(s,e);
