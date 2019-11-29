function w = coth_single (w1)
% coth function for signal and variance

w.s = coth(w1.s);
if ~isempty(w1.e)
    w.e = ((1-w.s.^2).^2).*w1.e;
else
    w.e = [];
end

w = class(w,'sigvar');
