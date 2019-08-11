function d=get_xsigerr(w)
% Get the x-axis, signal and error arrays for IX_dataset_1d dataset(s), together with distribution flags
%
%   >> d=get_xsigerr(w)
%
% Input:
% -----
%   w       IX_dataset_1d or array of IX_dataset_1d
%
% Output:
% -------
%   d       Structure or stucture array with same size and shape as the array of IX_dataset_1d
%           Field for ith dataset are
%               d(i).x              Cell array of arrays containing the x axis baoundaries or points
%               d(i).signal         Signal array
%               d(i).err            Array of standard deviations
%               d(i).distribution   true if a distribution, false if not

if numel(w)==1
    d=struct('x',{{w.x}},'signal',w.signal,'err',w.error,'distribution',w.x_distribution);
elseif numel(w)>1
    d=struct('x',{{w(1).x}},'signal',w(1).signal,'err',w(1).error,'distribution',w(1).x_distribution);
    if numel(w)>1
        d=repmat(d,size(w));
        for i=2:numel(w)
            d(i)=struct('x',{{w(i).x}},'signal',w(i).signal,'err',w(i).error,'distribution',w(i).x_distribution);
        end
    end
else
    d=struct('x',{},'signal',{},'err',{},'distribution',{});
end
