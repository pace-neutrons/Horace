function wout = IX_dataset_1d (w)
% Convert 1D sqw object into IX_dataset_1d
%
%   >> wout = IX_dataset_1d (w)

% Check input
is1d = arrayfun(@(x)(dimensions(x)==1),w);
if ~all(is1d)
    cl_name = class(w);
    Err_base =['HORACE:',cl_name,':invalid_argument'];
    if numel(w)==1
        error(Err_base , ...
            'sqw object is not one-dimensional')
    else
        error(Err_base, ...
            'Not all elements in the array of sqw objects are one dimensional')
    end
end


wout = arrayfun(@(x)(x.data.IX_dataset_1d()),w);
