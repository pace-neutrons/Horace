function w = acsc_single (w1)
% arccosecant function for signal and variance

s = acsc(w1.signal_);
if ~isempty(w1.variance_)
    e = w1.variance_./(abs(s.^2-1).*(s.^2));     % ensure positive
else
    e = [];
end

w = sigvar2(s,e);
