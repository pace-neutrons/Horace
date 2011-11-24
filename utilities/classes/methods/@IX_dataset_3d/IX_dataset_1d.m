function w1 = IX_dataset_1d(w3)
% Create an array of IX_dataset_1d object from an array of IX_dataset_3d objects
%
%   >> w1 = IX_dataset_1d (w3)

nw3=numel(w3);
nw1=zeros(nw3,1);
for i=1:nw3
    sz=size(w3(i).signal);
    nw1(i)=sz(2)*sz(3);
end
ibegw1=[0;cumsum(nw1)];

w1=repmat(IX_dataset_1d,sum(nw1),1);
for i=1:nw3
    title=w3(i).title;      % get contents into temporary variables to avoid repeated call to IX_dataset_2d/get
    signal=w3(i).signal;
    error=w3(i).error;
    s_axis=w3(i).s_axis;
    x=w3(i).x; x_axis=w3(i).x_axis; x_distribution=w3(i).x_distribution;
    for j=1:nw1(i)
        w1(ibegw1(i)+j)=IX_dataset_1d(title, signal(:,j), error(:,j), s_axis, x, x_axis, x_distribution);
    end
end
