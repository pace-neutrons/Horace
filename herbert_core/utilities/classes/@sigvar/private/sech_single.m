function w = sech_single (w1)
% sech function for signal and variance

s = sech(w1.signal_);
if ~isempty(w1.variance_)
    e = abs(1-s.^2).*(s.^2).*w1.variance_;     % ensure positive
else
    e = [];
end

w = sigvar(s,e);
