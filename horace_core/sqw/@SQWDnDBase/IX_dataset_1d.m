function wout = IX_dataset_1d (w)
% Convert 1D sqw object into IX_dataset_1d
%
%   >> wout = IX_dataset_1d (w)

% Check input
for i=1:numel(w)
    if dimensions(w(i))~=1
        if numel(w)==1
            error('HORACE:SQWDndBase:invalid_argument', ...
                'sqw object is not one dimensional')
        else
            error('HORACE:SQWDndBase:invalid_argument', ...
                'Not all elements in the array of sqw objects are one dimensional')
        end
    end
end
wout = arrayfun(@(x)(x.data.IX_dataset_1d()),w);
