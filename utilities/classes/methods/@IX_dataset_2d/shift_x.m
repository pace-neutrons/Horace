function wout = shift_x(w,x)
% Shift an IX_dataset_2d object or array of IX_dataset_2d objects along the x-axis
%
%   >> wout = shift_x(w,x)
%
%   w   IX_dataset_2d object or array of IX_dataset_2d objects
%   x   scalar shift, or array of shifts with size matching that of array w

wout=w;
if numel(w)>1 && numel(x)==1
    x=repmat(x,size(w));
elseif numel(w)~=numel(x)
    error('Check number of IX_dataset_2d objects and elements in the shift array')
end

for i=1:numel(w)
    wout(i).x = w(i).x + x(i);
end
