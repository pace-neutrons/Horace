function wout = scale(w,x)
% Rescale the x and y axes of an IX_dataset_2d object or array of IX_dataset_2d objects
%
%   >> wout = shift_x(w,x)
%
%   w   IX_dataset_2d object or array of IX_dataset_2d objects
%   x   Vector length two giving scale factors along x and y axes
%      OR
%       Array with outer dimension length two and whose inner dimensions
%       have number of elements matching that of array w
%        e.g. numel(w)=12, and size(x)=[12,2]; x(:,1) give rescaling of
%             x-axis and x(:,2) gives rescale of y axes.

wout=w;
sz=size(x);
nd=dimensions(w(1));

% Check input: this is independent of dimensionality once nd and sz are given
if isvector(x)
    if numel(x)==nd
        x=repmat(x(:)',[numel(w),1]);   % n x 2 array
    else
        error(['Check number of components of scale vector equals ',num2str(nd)])
    end
elseif sz(end)==nd
    if prod(sz(1:end-1))==numel(w)
        x=reshape(x,[prod(sz(1:end-1)),nd]);
    else
        error(['Check number of IX_dataset_',num2str(nd),'d objects and elements in the scale array'])
    end
else
    error('Check number of components of scale vectors')
end

% Perform shift
for i=1:numel(w)
    wout(i).x = w(i).x * x(i,1);
    wout(i).y = w(i).y * x(i,2);
end
