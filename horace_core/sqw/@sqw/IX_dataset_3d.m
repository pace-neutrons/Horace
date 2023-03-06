function wout = IX_dataset_3d (w)
% Convert 3D sqw object into IX_dataset_3d
%
%   >> wout = IX_dataset_3d (w)

% R.A. Ewings, 14/10/08.


% Check input
is3d = arrayfun(@(x)(dimensions(x)==3),w);
if ~all(is3d)
    if numel(w)==1
        error('HORACE:sqw:invalid_argument', ...
            'sqw object is not a three-dimensional object')
    else
        error('HORACE:sqw:invalid_argument', ...
            'Not all elements in the array of sqw objects are three-dimensional')
    end
end
wout = arrayfun(@(x)(x.data.IX_dataset_3d()),w);
wout=reshape(wout,size(w));
