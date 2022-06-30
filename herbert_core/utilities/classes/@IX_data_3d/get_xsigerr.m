function d=get_xsigerr(w)
% Get the x-axis, signal and error arrays for IX_dataset_3d dataset(s), together with distribution flags
%
%   >> d=get_xsigerr(w)
%
% Input:
% -----
%   w       IX_dataset_3d or array of IX_dataset_3d
%
% Output:
% -------
%   d       Structure or stucture array with same size and shape as the array of IX_dataset_3d
%           Field for ith dataset are
%               d(i).x              Cell array of arrays containing the x axis baoundaries or points
%               d(i).signal         Signal array
%               d(i).err            Array of standard deviations
%               d(i).distribution   Array of elements, one per axis, that is true if a distribution, false if not

if numel(w)==1
    d=struct('x',{{w.x,w.y,w.z}},'signal',w.signal,'err',w.error,...
        'distribution',[w.x_distribution,w.y_distribution,w.z_distribution]);
elseif numel(w)>1
    d=struct('x',{{w(1).x,w(1).y,w(1).z}},'signal',w(1).signal,'err',w(1).error,...
        'distribution',[w(1).x_distribution,w(1).y_distribution,w(1).z_distribution]);
    if numel(w)>1
        d=repmat(d,size(w));
        for i=2:numel(w)
            d(i)=struct('x',{{w(i).x,w(i).y,w(i).z}},'signal',w(i).signal,'err',w(i).error,...
                'distribution',[w(i).x_distribution,w(i).y_distribution,w(i).z_distribution]);
        end
    end
else
    d=struct('x',{},'signal',{},'err',{},'distribution',{});
end
