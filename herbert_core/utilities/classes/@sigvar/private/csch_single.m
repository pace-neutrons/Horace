function w = csch_single (w1)
% hyperbolic cosecant function for signal and variance

s = csch(w1.signal_);
if ~isempty(w1.variance_)
    e = (s.^2+1).*(s.^2).*w1.variance_;
else
    e = [];
end

w = sigvar(s,e);
