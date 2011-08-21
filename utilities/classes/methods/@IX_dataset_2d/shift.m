function wout = shift(w,x)
% Shift an IX_dataset_2d object or array of IX_dataset_2d objects along the x and y axes
%
%   >> wout = shift_x(w,x)
%
%   w   IX_dataset_2d object or array of IX_dataset_2d objects
%   x   Vector length two giving shift along x and y axes
%      OR
%       Array with outer dimension length two and whose inner dimensions
%       have number of elements matching that of array w
%        e.g. numel(w)=12, and size(x)=[12,2]; x(:,1) give shifts along
%             x-axis and x(:,2) give shifts along y axes.

wout=w;
sz=size(x);
nd=dimensions(w(1));

% Check input: this is independent of dimensionality once nd and sz are given
if isvector(x)
    if numel(x)==nd
        x=repmat(x(:)',[numel(w),1]);   % n x 2 array
    else
        error(['Check number of components of shift vector equals ',num2str(nd)])
    end
elseif sz(end)==nd
    if prod(sz(1:end-1))==numel(w)
        x=reshape(x,[prod(sz(1:end-1)),nd]);
    else
        error(['Check number of IX_dataset_',num2str(nd),'d objects and elements in the shift array'])
    end
else
    error('Check number of components of shift vectors')
end

% Perform shift
for i=1:numel(w)
    wout(i).x = w(i).x + x(i,1);
    wout(i).y = w(i).y + x(i,2);
end
