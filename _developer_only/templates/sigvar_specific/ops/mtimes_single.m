function w = mtimes_single (w1, w2)
% Multiply two arrays with variances, element by element

w.s = w1.s .* w2.s;

if ~isempty(w1.e) && ~isempty(w2.e)
    w.e = (w2.s.^2).*w1.e + (w1.s.^2).*w2.e;
elseif ~isempty(w1.e)
    w.e = (w2.s.^2).*w1.e;
elseif ~isempty(w2.e)
    w.e = (w1.s.^2).*w2.e;
else
    w.e = [];
end
        
