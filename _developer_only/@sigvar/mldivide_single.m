function w = mldivide_single (w1, w2)
% Divide one array with variance by another, element by element

w.s = w2.s ./ w1.s;

if ~isempty(w2.e) && ~isempty(w1.e)
    w.e = w2.e./(w1.s.^2) + w1.e.*((w.s./w1.s).^2);
elseif ~isempty(w2.e)
    w.e = w2.e./(w1.s.^2);
elseif ~isempty(w1.e)
    w.e = w1.e.*((w.s./w1.s).^2);
else
    w.e = [];
end
        
w = class(w,'sigvar');
