function w = mrdivide_single (w1, w2)
% Divide one array with variance by another, element by element

w.s = w1.s ./ w2.s;

if ~isempty(w1.e) && ~isempty(w2.e)
    w.e = w1.e./(w2.s.^2) + w2.e.*((w.s./w2.s).^2);
elseif ~isempty(w1.e)
    w.e = w1.e./(w2.s.^2);
elseif ~isempty(w2.e)
    w.e = w2.e.*((w.s./w2.s).^2);
else
    w.e = [];
end
        
w = class(w,'sigvar');
