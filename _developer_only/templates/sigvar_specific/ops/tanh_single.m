function w = tanh_single (w1)
% tanh function for signal and variance

w.s = tanh(w1.s);
if ~isempty(w1.e)
    w.e = ((1-w.s.^2).^2).*w1.e;
else
    w.e = [];
end

w = class(w,'sigvar');
