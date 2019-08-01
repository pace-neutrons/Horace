function wout = shift_y(w,y)
% Shift an IX_dataset_3d object or array of IX_dataset_3d objects along the y-axis
%
%   >> wout = shift_y(w,y)
%
%   w   IX_dataset_3d object or array of IX_dataset_3d objects
%   y   scalar shift, or array of shifts with size matching that of array w

wout=w;
if numel(w)>1 && numel(y)==1
    y=repmat(y,size(w));
elseif numel(w)~=numel(y)
    error('Check number of IX_dataset_3d objects and elements in the shift array')
end

for i=1:numel(w)
    wout(i).y = w(i).y + y(i);
end
