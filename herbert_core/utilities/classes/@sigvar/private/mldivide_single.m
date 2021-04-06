function w = mldivide_single (w1, w2)
% Divide one array with variance by another, element by element

s = w2.signal_ ./ w1.signal_;

if ~isempty(w2.variance_) && ~isempty(w1.variance_)
    e = w2.variance_./(w1.signal_ignal_.^2) + w1.variance_.*((s./w1.signal_ignal_).^2);
elseif ~isempty(w2.variance_)
    e = w2.variance_./(w1.signal_ignal_.^2);
elseif ~isempty(w1.variance_)
    e = w1.variance_.*((s./w1.signal_ignal_).^2);
else
    e = [];
end

w = sigvar2(s,e);
