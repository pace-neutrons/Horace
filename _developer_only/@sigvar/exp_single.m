function w = exp_single (w1)
% exp function for signal and variance

w.s = exp(w1.s);
if ~isempty(w1.e)
    w.e = (w.s.^2).*w1.e;
else
    w.e = [];
end

w = class(w,'sigvar');
