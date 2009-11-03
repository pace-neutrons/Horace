function w = mpower_single (w1, w2)
% Raise one array with variance to the power of another, element by element

tmp = w1.s .^ (w2.s-1);     % intermediate variable to save time calculating error bars
w.s = tmp .* w1.s;

if ~isempty(w1.e) && ~isempty(w2.e)
    w.e = ((w2.s.*tmp).^2).*w1.e + ((w.s.*log(w1.s)).^2).*w2.e;
elseif ~isempty(w1.e)
    w.e = (w2.s.^2).*w1.e;
elseif ~isempty(w2.e)
    w.e = (w1.s.^2).*w2.e;
else
    w.e = [];
end
        
w = class(w,'sigvar');
