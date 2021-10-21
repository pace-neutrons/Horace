function w = acos_single (w1)
% acos function for signal and variance

w.s = acos(w1.s);
if ~isempty(w1.e)
    w.e = w1.e./abs(1-w.s.^2);     % ensure positive
else
    w.e = [];
end

w = class(w,'sigvar');
