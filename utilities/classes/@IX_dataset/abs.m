function wout = abs(w)
% Take absolute value of an IX_dataset_nd object or array of IX_dataset_nd objects
%
%   >> wout = abs(w)

wout = w;

for i=1:numel(w)
    wout(i).signal_ = abs(wout(i).signal_);
end
