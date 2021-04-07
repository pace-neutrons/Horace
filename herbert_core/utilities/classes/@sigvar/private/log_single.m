function w = log_single (w1)
% log function for signal and variance

s = log(w1.signal_);
if ~isempty(w1.variance_)
    e = w1.variance_./w1.signal_.^2; 
else
    e = [];
end

w = sigvar(s,e);
