function w = log10_single (w1)
% log10 function for signal and variance

s = log10(w1.signal_);
if ~isempty(w1.variance_)
    e = w1.variance_./(w1.signal_*log(10)).^2; 
else
    e = [];
end

w = sigvar(s,e);
