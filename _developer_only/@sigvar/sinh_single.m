function w = sinh_single (w1)
% sinh function for signal and variance

w.s = sinh(w1.s);
if ~isempty(w1.e)
    w.e = (1+w.s.^2).*w1.e;
else
    w.e = [];
end

w = class(w,'sigvar');
