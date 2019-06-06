function w = debug_yvec (yvec,nbins)
% Histogram yvec and write to file

if ~exist('nbin','var')
    nbins = 250;
end

ncmp = size(yvec,1);
npix = size(yvec,2);

w = repmat(IX_dataset_1d,ncmp,1);
for i=1:ncmp
    title = ['Component ',num2str(i)];
    w(i) = histogram_array (yvec(i,:), nbins, title);
end
save(fullfile(tempdir,'histogram.mat'),'w')

%--------------------------------------------------------------------------
function w = histogram_array (vals, nbins, title)
% Histogram data

[N, edges] = histcounts(vals,nbins);
dx = diff(edges);
signal = N./dx;
error = sqrt(N)./dx;
w = IX_dataset_1d (edges, signal, error, title, 'independent variable', 'events per unit x');
