function wout = scale_z(w,zscale)
% Rescale the z-axis for an IX_dataset_3d object or array of IX_dataset_3d objects
%
%   >> wout = scale(w,zscale)
%
%   w   IX_dataset_3d object or array of IX_dataset_3d objects
%   z   Rescaling factor: scalar or array of values with size matching that of array w

wout=w;
if numel(w)>1 && numel(zscale)==1
    zscale=repmat(zscale,size(w));
elseif numel(w)~=numel(zscale)
    error('Check number of elements in IX_dataset_3d and scale arrays')
end

for i=1:numel(w)
    wout(i).z = w(i).z * zscale(i);
end
