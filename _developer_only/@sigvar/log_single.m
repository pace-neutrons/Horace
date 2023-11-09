function w = log_single (w1)
% log function for signal and variance

w.s = log(w1.s);
if ~isempty(w1.e)
    w.e = w1.e./w1.s.^2; 
else
    w.e = [];
end

w = class(w,'sigvar');
