function w = asec_single (w1)
% asec function for signal and variance

w.s = asec(w1.s);
if ~isempty(w1.e)
    w.e = w1.e./(abs(w.s.^2-1).*(w.s.^2));     % ensure positive
else
    w.e = [];
end

w = class(w,'sigvar');
