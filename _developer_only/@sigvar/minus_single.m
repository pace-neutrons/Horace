function w = minus_single (w1, w2)
% Take difference between two arrays with variances

w.s = w1.s - w2.s;

if ~isempty(w1.e) && ~isempty(w2.e)
    w.e = w1.e + w2.e;
elseif ~isempty(w1.e)
    w.e = w1.e;
elseif ~isempty(w2.e)
    w.e = w2.e;
else
    w.e = [];
end

w = class(w,'sigvar');
