function w = atanh_single (w1)
% atanh function for signal and variance

w.s = atanh(w1.s);
if ~isempty(w1.e)
    w.e = w1.e./((1-w.s.^2).^2);
else
    w.e = [];
end

w = class(w,'sigvar');
