function w = acsc_single (w1)
% arccosecant function for signal and variance

w.s = acsc(w1.s);
if ~isempty(w1.e)
    w.e = w1.e./(abs(w.s.^2-1).*(w.s.^2));     % ensure positive
else
    w.e = [];
end

w = class(w,'sigvar');
