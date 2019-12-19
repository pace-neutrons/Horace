function wout = combine_sqw_same_bins (varargin)
% Combine sqw objects that are assumed to have the same size s,e,npix arrays
% Only s,e,npix are altered; all the other properties come from the first
% object in the input argument list
%
%   >> wout = combine_sqw_same_bins (w1,w2,w3...)

wout = varargin{1};
% Trivial case of just one input argument
if numel(varargin)==1
    return
end

% More than one sqw object
% ------------------------
nw = numel(varargin);   % number of sqw objects
nbin = numel(varargin{1}.data.npix);     % number of bins in each sqw object

% Total number of pixels in each sqw object
npixtot = cellfun (@(x)size(x.data.pix,2),varargin);    
npixtot_all = sum(npixtot);     % total number of pixels in all sqw objects

% Get the index of unique pixels in the concatenated pix array
% Look only at irun, idet, ien, as the pix coordinates may have been altered by
% the symmetrisation algorithm, depending on where that is done.
nend = cumsum(npixtot);
nbeg = nend - npixtot + 1;
pixind = zeros(npixtot_all,3);
for i=1:nw
    pixind(nbeg(i):nend(i),:) = varargin{i}.data.pix(5:7,:)';
end
[~,ix_all] = unique(pixind,'rows','first');     % indicies to first occurence
clear pixind    % clear a large work array

ibin = zeros(npixtot_all,1);
for i=1:nw
    ibin(nbeg(i):nend(i)) = replicate_iarray (1:nbin,varargin{i}.data.npix);
end
ibin = ibin(ix_all);

[ibin,ind] = sort(ibin);    % sort bins according to increasing index
ix_all = ix_all(ind);       % sort index into pix to same order

% Updated number of pixels in each bin
sz = size(wout.data.npix);
wout.data.npix = reshape (accumarray (ibin,1,[prod(sz),1]), sz);
clear ibin      % clear a large work array

% Get the full pix array
pix = zeros(9,npixtot_all);
for i=1:nw
    pix(:,nbeg(i):nend(i)) = varargin{i}.data.pix;
end
wout.data.pix = pix(:,ix_all);

% Recompute the singal and error arrays
wout=recompute_bin_data(wout);
