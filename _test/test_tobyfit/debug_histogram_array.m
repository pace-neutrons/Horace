function debug_histogram_array (vals,title,xunits)
% Histogram the array and write to file
%
%   >> debug_histogram_array (vals,title,xunits)
%
% Saves as a IX_dataset_1d object in file: fullfile(tempdir,'histogram.mat')

% Has a name beginning with debug so that it is apparent it is a debug tool

nbins = 250;
[N, edges] = histcounts(vals,nbins);
dx = diff(edges);
signal = N./dx;
error = sqrt(N)./dx;
w = IX_dataset_1d(edges, signal, error, title, xunits, 'events');
save(fullfile(tempdir,'histogram.mat'),'w')
