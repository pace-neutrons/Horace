function wout = scale_y(w,yscale)
% Rescale the y-axis for an IX_dataset_2d object or array of IX_dataset_2d objects
%
%   >> wout = scale(w,yscale)
%
%   w   IX_dataset_2d object or array of IX_dataset_2d objects
%   y   Rescaling factor: scalar or array of values with size matching that of array w

wout=w;
if numel(w)>1 && numel(yscale)==1
    yscale=repmat(yscale,size(w));
elseif numel(w)~=numel(yscale)
    error('Check number of elements in IX_dataset_2d and scale arrays')
end

for i=1:numel(w)
    wout(i).y = w(i).y * yscale(i);
end
