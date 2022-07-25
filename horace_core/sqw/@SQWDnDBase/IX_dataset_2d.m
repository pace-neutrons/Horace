function wout = IX_dataset_2d (w)
% Convert 2D sqw object(s) into IX_dataset_2d(s)
%
%   >> wout = IX_dataset_2d (w)

% Original author: T.G.Perring
%
is2d = arrayfun(@(x)(dimensions(x)==2),w);
if ~all(is2d)
    cl_name = class(w);
    Err_base =['HORACE:',cl_name,':invalid_argument'];
    if numel(w)==1
        error(Err_base , ...
            'sqw object is not two-dimensional')
    else
        error(Err_base, ...
            'Not all elements in the array of sqw objects are two-dimensional')
    end

end
wout = arrayfun(@(x)(x.data.IX_dataset_2d()),w);
