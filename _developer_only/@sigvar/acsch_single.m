function w = acsch_single (w1)
% hyperbolic arccosecant function for signal and variance

w.s = acsch(w1.s);
if ~isempty(w1.e)
    w.e = w1.e./((w.s.^2+1).*(w.s.^2));
else
    w.e = [];
end

w = class(w,'sigvar');
