function w = log10_single (w1)
% log10 function for signal and variance

w.s = log10(w1.s);
if ~isempty(w1.e)
    w.e = w1.e./(w1.s*log(10)).^2; 
else
    w.e = [];
end

w = class(w,'sigvar');
