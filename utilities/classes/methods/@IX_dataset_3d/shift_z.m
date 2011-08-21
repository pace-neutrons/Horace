function wout = shift_z(w,z)
% Shift an IX_dataset_3d object or array of IX_dataset_3d objects along the z-axis
%
%   >> wout = shift_z(w,z)
%
%   w   IX_dataset_3d object or array of IX_dataset_3d objects
%   z   scalar shift, or array of shifts with size matching that of array w

wout=w;
if numel(w)>1 && numel(z)==1
    z=repmat(z,size(w));
elseif numel(w)~=numel(z)
    error('Check number of IX_dataset_3d objects and elements in the shift array')
end

for i=1:numel(w)
    wout(i).z = w(i).z + z(i);
end
