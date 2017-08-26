function wout = abs(w)
% Take absolute value of an IX_dataset_2d object or array of IX_dataset_2d objects
%
%   >> wout = abs(w)

wout = w;

for i=1:numel(w)
    wout.signal = abs(wout.signal);
end
