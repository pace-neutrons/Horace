function w = sinh_single (w1)
% sinh function for signal and variance

s = sinh(w1.signal_);
if ~isempty(w1.variance_)
    e = (1+s.^2).*w1.variance_;
else
    e = [];
end

w = sigvar(s,e);
