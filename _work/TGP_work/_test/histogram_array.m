function w=hist_it(n)
% Create a IX_dataset_1d histogram of an array

[y,x]=histcounts(n(:));
dx=diff(x);
y=y./dx;
w=IX_dataset_1d(x,y);
