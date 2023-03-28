function wout = IX_dataset_2d (w)
% Convert 2D sqw object(s) into IX_dataset_2d(s)
%
%   >> wout = IX_dataset_2d (w)

% Original author: T.G.Perring
%
is2d = arrayfun(@(x)(dimensions(x)==2),w);
if ~all(is2d)
    if numel(w)==1
        error('HORACE:sqw:invalid_argument', ...
            'sqw object is not two-dimensional object')
    else
        error('HORACE:sqw:invalid_argument', ...
            'Not all elements in the array of sqw objects are two-dimensional')
    end
end
wout = arrayfun(@(x)(x.data.IX_dataset_2d()),w);
