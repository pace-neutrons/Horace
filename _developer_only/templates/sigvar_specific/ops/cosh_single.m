function w = cosh_single (w1)
% cosh function for signal and variance

w.s = cosh(w1.s);
if ~isempty(w1.e)
    w.e = abs(w.s.^2-1).*w1.e;     % ensure positive
else
    w.e = [];
end

w = class(w,'sigvar');
