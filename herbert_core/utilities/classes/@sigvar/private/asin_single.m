function w = asin_single (w1)
% asin function for signal and variance

s = asin(w1.signal_);
if ~isempty(w1.variance_)
    e = w1.variance_./abs(1-s.^2);     % ensure positive
else
    e = [];
end

w = sigvar(s,e);
