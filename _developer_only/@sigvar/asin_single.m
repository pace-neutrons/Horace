function w = asin_single (w1)
% asin function for signal and variance

w.s = asin(w1.s);
if ~isempty(w1.e)
    w.e = w1.e./abs(1-w.s.^2);     % ensure positive
else
    w.e = [];
end

w = class(w,'sigvar');
