function w = atanh_single (w1)
% atanh function for signal and variance

s = atanh(w1.signal_);
if ~isempty(w1.e)
    e = w1.e./((1-s.^2).^2);
else
    e = [];
end

w = sigvar2(s,e);
