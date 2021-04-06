function w = acos_single (w1)
% acos function for signal and variance

s = acos(w1.signal_);
if ~isempty(w1.variance_)
    e = w1.variance_./abs(1-s.^2);     % ensure positive
else
    e = [];
end

w = sigvar2(s,e);
