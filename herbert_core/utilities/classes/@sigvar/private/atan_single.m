function w = atan_single (w1)
% atan function for signal and variance

s = atan(w1.signal_);
if ~isempty(w1.variance_)
    e = w1.variance_./((1+s.^2).^2);
else
    e = [];
end

w = sigvar2(s,e);
