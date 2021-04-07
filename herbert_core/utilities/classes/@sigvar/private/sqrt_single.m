function w = sqrt_single (w1)
% sqrt function for signal and variance

s = sqrt(w1.signal_);
if ~isempty(w1.variance_)
    e = w1.variance_./(4*w1.signal_); 
else
    e = [];
end

w = sigvar(s,e);
