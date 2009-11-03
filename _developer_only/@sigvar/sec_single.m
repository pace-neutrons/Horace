function w = sec_single (w1)
% sec function for signal and variance

w.s = sec(w1.s);
if ~isempty(w1.e)
    w.e = abs(w.s.^2-1).*(w.s.^2).*w1.e;     % ensure positive
else
    w.e = [];
end

w = class(w,'sigvar');
