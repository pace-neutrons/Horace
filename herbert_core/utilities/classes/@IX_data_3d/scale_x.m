function wout = scale_x(w,xscale)
% Rescale the x-axis for an IX_dataset_3d object or array of IX_dataset_3d objects
%
%   >> wout = scale(w,xscale)
%
%   w   IX_dataset_3d object or array of IX_dataset_3d objects
%   x   Rescaling factor: scalar or array of values with size matching that of array w

wout=w;
if numel(w)>1 && numel(xscale)==1
    xscale=repmat(xscale,size(w));
elseif numel(w)~=numel(xscale)
    error('Check number of elements in IX_dataset_3d and scale arrays')
end

for i=1:numel(w)
    wout(i).x = w(i).x * xscale(i);
end
