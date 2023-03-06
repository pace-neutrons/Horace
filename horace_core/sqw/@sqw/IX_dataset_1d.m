function wout = IX_dataset_1d (w)
% Convert 1D sqw object into IX_dataset_1d
%
%   >> wout = IX_dataset_1d (w)

% Check input
is1d = arrayfun(@(x)(dimensions(x)==1),w);
if ~all(is1d)
    if numel(w)==1
        error('HORACE:sqw:invalid_argument', ...
            'sqw object is not one-dimensional')
    else
        error('HORACE:sqw:invalid_argument', ...
            'Not all elements in the array of sqw objects are one dimensional')
    end
end
wout = arrayfun(@(x)(x.data.IX_dataset_1d()),w);
