function w = tanh_single (w1)
% tanh function for signal and variance

s = tanh(w1.signal_);
if ~isempty(w1.variance_)
    e = ((1-s.^2).^2).*w1.variance_;
else
    e = [];
end

w = sigvar(s,e);
