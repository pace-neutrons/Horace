function w = acoth_single (w1)
% acoth function for signal and variance

s = acoth(w1.signal_);
if ~isempty(w1.variance_)
    e = w1.variance_./((1-s.^2).^2);
else
    e = [];
end

w = sigvar2(s,e);
