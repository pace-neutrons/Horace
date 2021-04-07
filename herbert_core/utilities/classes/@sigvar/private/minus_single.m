function w = minus_single (w1, w2)
% Take difference between two arrays with variances

s = w1.signal_ - w2.signal_;

if ~isempty(w1.variance_) && ~isempty(w2.variance_)
    e = w1.variance_ + w2.variance_;
elseif ~isempty(w1.variance_)
    e = w1.variance_;
elseif ~isempty(w2.variance_)
    e = w2.variance_;
else
    e = [];
end

w = sigvar(s,e);
