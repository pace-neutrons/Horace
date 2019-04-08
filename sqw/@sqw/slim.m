function wout = slim (win, reduce)
% Slim an sqw object by removing random pixels
%
%   >> wout = slim (win, factor)
%
% Input:
% ------
%   win     Input sqw object or array of sqw objects
%   reduce  Factor by which to reduce the number of pixels (reduce >=1)
%          e.g. reduce=5 will reduce the number of pixels by a factor 5.
%
% Output:
% -------
%   wout    Output sqw object or array of szqw objects


% Original author: T.G.Perring
%
% $Revision:: 1720 ($Date:: 2019-04-08 16:49:36 +0100 (Mon, 8 Apr 2019) $)


% Check input
if ~(isnumeric(reduce) && isscalar(reduce) && isfinite(reduce) && reduce>=1)
    error ('Input argument ''reduce'' must be greater or equal to unity')
end

% Perform action using existing sqw methods for masking pixels
wout = win;
if reduce>1     % nothing to do if reduce==1
    for i=1:numel(wout)
        npix = size(wout.data.pix,2);
        npix_keep = round(npix/reduce);
        mask_arr = randi_unique(npix,npix_keep);
        wout(i) = mask_pixels(win(i),mask_arr);
    end
end

%========================================================================================
function keep = randi_unique (imax, n)
% Select n unique random integers in the range 1 to imax
if n>imax
    error('Number of indicies to select must be less than or equal to the vector length')
end
keep = false(imax,1);
keep(randi(imax,n,1)) = true;
nkeep = sum(keep);
while nkeep<n
    tmp = keep(~keep);
    tmp(randi(numel(tmp),n-nkeep,1)) = true;
    keep(~keep) = tmp;
    nkeep = sum(keep);
end
