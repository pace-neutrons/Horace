function wout = IX_dataset_2d (w)
% Convert 2D sqw object(s) into IX_dataset_2d(s)
%
%   >> wout = IX_dataset_2d (w)

% Original author: T.G.Perring
%
for i=1:numel(w)
    if dimensions(w(i))~=2
        if numel(w)==1
            error('HORACE:SQWDndBase:invalid_argument', ...
                'sqw object is not two-dimensional')
        else
            error('HORACE:SQWDndBase:invalid_argument', ...
                'Not all elements in the array of sqw objects are two-dimensional')
        end
    end
end

wout = arrayfun(@(x)(x.data.IX_dataset_2d()),w);
