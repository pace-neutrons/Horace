function w = asinh_single (w1)
% asinh function for signal and variance

s = asinh(w1.signal_);
if ~isempty(w1.variance_)
    e = w1.variance_./(1+s.^2);
else
    e = [];
end

w = sigvar(s,e);
