function w = sin_single (w1)
% sin function for signal and variance

w.s = sin(w1.s);
if ~isempty(w1.e)
    w.e = abs(1-w.s.^2).*w1.e;     % ensure positive
else
    w.e = [];
end

w = class(w,'sigvar');
