function w = sqrt_single (w1)
% sqrt function for signal and variance

w.s = sqrt(w1.s);
if ~isempty(w1.e)
    w.e = w1.e./(4*w1.s); 
else
    w.e = [];
end

w = class(w,'sigvar');
