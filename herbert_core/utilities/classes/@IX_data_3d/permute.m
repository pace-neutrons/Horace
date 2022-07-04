function wout=permute(w,order)
% Permute the axes of an IX_dataset_3D
%
%   >> wout=permute(w,order)
%
%   w       Input IX_dataset_3D or array of IX_dataset_3D
%   order   Order of axes e.g. [2,3,1]

% Trivial case of no permutation requested
if nargin==1
    wout=w;
    return
end

% Check input
nd=dimensions(w);
if any(mod(order,1)~=0)||numel(order)~=nd||~isrowvector(order)||any(sort(order)~=(1:nd))
    error(['Order must be a row vector with a permutation of the numbers 1-',num2str(nd)])
end

% Catch trivial case of no permutation
if all(order==(1:nd))
    wout=w;
    return
end

% Perform permutation
% (The following could be made generic for all dimensions, but IX_dataset_nd will perform checks we dont need)
wout=repmat(IX_dataset_3d,size(w));
for iw=1:numel(w)
    wout(iw).title=w(iw).title;
    wout(iw).signal=permute(w(iw).signal,order);
    wout(iw).error=permute(w(iw).error,order);
    wout(iw).s_axis=w(iw).s_axis;
    ax=axis(w(iw),order);
    wout(iw).x=ax(1).values;
    wout(iw).x_axis=ax(1).axis;
    wout(iw).x_distribution=ax(1).distribution;
    wout(iw).y=ax(2).values;
    wout(iw).y_axis=ax(2).axis;
    wout(iw).y_distribution=ax(2).distribution;
    wout(iw).z=ax(3).values;
    wout(iw).z_axis=ax(3).axis;
    wout(iw).z_distribution=ax(3).distribution;
end
