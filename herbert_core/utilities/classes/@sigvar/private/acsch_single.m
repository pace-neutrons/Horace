function w = acsch_single (w1)
% hyperbolic arccosecant function for signal and variance

s = acsch(w1.signal_);
if ~isempty(w1.variance_)
    e = w1.variance_./((s.^2+1).*(s.^2));
else
    e = [];
end

w = sigvar2(s,e);
