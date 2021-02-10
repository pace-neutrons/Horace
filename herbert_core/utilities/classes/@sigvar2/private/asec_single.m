function w = asec_single (w1)
% asec function for signal and variance

s = asec(w1.signal_);
if ~isempty(w1.variance_)
    e = w1.variance_./(abs(s.^2-1).*(s.^2));     % ensure positive
else
    e = [];
end

w = sigvar2(s,e);
