function w1 = IX_dataset_1d(w2)
% Create an array of IX_dataset_1d object from an array of IX_dataset_1d objects
%
%   >> w2 = IX_dataset_2d (w1)

nw2=numel(w2);
nw1=zeros(nw2,1);
for i=1:nw2
    nw1(i)=size(w2(i).signal,2);
end
ibegw1=[0;cumsum(nw1)];

w1=repmat(IX_dataset_1d,sum(nw1),1);
for i=1:nw2
    title=w2(i).title;      % get contents into temporary variables to avoid repeated call to IX_dataset_2d/get
    signal=w2(i).signal;
    error=w2(i).error;
    s_axis=w2(i).s_axis;
    x=w2(i).x; x_axis=w2(i).x_axis; x_distribution=w2(i).x_distribution;
    for j=1:nw1(i)
        w1(ibegw1(i)+j)=IX_dataset_1d(title, signal(:,j), error(:,j), s_axis, x, x_axis, x_distribution);
    end
end
