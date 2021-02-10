function w = mrdivide_single (w1, w2)
% Divide one array with variance by another, element by element

s = w1.signal_ ./ w2.signal_;

if ~isempty(w1.variance_) && ~isempty(w2.variance_)
    e = w1.variance_./(w2.signal_.^2) + w2.variance_.*((s./w2.signal_).^2);
elseif ~isempty(w1.variance_)
    e = w1.variance_./(w2.signal_.^2);
elseif ~isempty(w2.variance_)
    e = w2.variance_.*((s./w2.signal_).^2);
else
    e = [];
end

w = sigvar2(s,e);
