function w = mtimes_single (w1, w2)
% Multiply two arrays with variances, element by element

s = w1.signal_ .* w2.signal_;

if ~isempty(w1.variance_) && ~isempty(w2.variance_)
    e = (w2.signal_.^2).*w1.variance_ + (w1.signal_.^2).*w2.variance_;
elseif ~isempty(w1.variance_)
    e = (w2.signal_.^2).*w1.variance_;
elseif ~isempty(w2.variance_)
    e = (w1.signal_.^2).*w2.variance_;
else
    e = [];
end

w = sigvar(s,e);
