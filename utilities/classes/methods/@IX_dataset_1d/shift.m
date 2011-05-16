function wout = shift(w,x)
% Shift an IX_dataset_1d object or array of IX_dataset_1d objects along the x-axis
%
%   >> wout = shift(w,x)
%
%   w   IX_dataset_1d object or array of IX_dataset_1d objects
%   x   scalar shift, or array of shifts with size matching that of array w

wout=w;
if numel(w)>1 && numel(x)==1
    x=repmat(x,size(w));
elseif numel(w)~=numel(x)
    error('Check number of elements in IX_dataset_1d and shift arrays')
end

for i=1:numel(w)
    wout(i).x = w(i).x + x(i);
end
