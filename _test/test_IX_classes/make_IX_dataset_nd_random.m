function w=make_test_IX_dataset_nd(sz)
% Create IX_datset_nd with random signal and error
%
%   >> w=make_test_IX_dataset_nd(sz)     % size e.g. [17] (1D), [3,4] (2D), [20,20,1] (3D)
%
% Author: T.G.Perring

ndim=numel(sz);
ax=repmat(struct('values',{},'axis',{},'distribution',{}),[1,ndim]);
for i=1:ndim
    ax(i).values=1:sz(i);
    ax(i).axis=IX_axis(['Axis ',num2str(i)]);
    ax(i).distribution=false;
end
signal=10*rand([sz,1]);
err=rand([sz,1]);
title=['Test IX_dataset_',num2str(ndim),'d'];
s_axis=IX_axis('Counts');
w = IX_dataset_nd (title, signal, err, s_axis, ax);
