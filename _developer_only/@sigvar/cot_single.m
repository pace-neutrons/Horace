function w = cot_single (w1)
% cot function for signal and variance

w.s = cot(w1.s);
if ~isempty(w1.e)
    w.e = ((1+w.s.^2).^2).*w1.e;
else
    w.e = [];
end

w = class(w,'sigvar');
