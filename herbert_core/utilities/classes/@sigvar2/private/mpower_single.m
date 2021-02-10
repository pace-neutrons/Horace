function w = mpower_single (w1, w2)
% Raise one array with variance to the power of another, element by element

tmp = w1.signal_ .^ (w2.signal_-1);     % intermediate variable to save time calculating error bars
s = tmp .* w1.signal_;

if ~isempty(w1.variance_) && ~isempty(w2.variance_)
    e = ((w2.signal_.*tmp).^2).*w1.variance_ + ((s.*log(w1.signal_)).^2).*w2.variance_;
elseif ~isempty(w1.variance_)
    e = (w2.signal_.^2).*w1.variance_;
elseif ~isempty(w2.variance_)
    e = (w1.signal_.^2).*w2.variance_;
else
    e = [];
end

w = sigvar2(s,e);
