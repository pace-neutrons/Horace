function w = csch_single (w1)
% hyperbolic cosecant function for signal and variance

w.s = csch(w1.s);
if ~isempty(w1.e)
    w.e = (w.s.^2+1).*(w.s.^2).*w1.e;
else
    w.e = [];
end

w = class(w,'sigvar');
