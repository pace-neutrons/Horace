function [ix,npix,p,grid_size,ibin]=sort_pixels(u,urange,grid_size_in)
% Reorder the pixels according to increasing bin index in a Cartesian grid.
%
%   >> [ix,npix,p,grid_size]=sort_pixels(u,urange,grid_size_in)
%
% (In the following, nd=no. dimensions, npix_in=no. pixels on input, npix=no. pixels in urange)
%
% Input:
% ------
%   u               [nd x npix_in] array of the coordinates in Cartesian grid
%   urange          Range for the grid (2 x nd)
%   grid_size_in    Scalar or row vector (1 x nd) of number of bins along each axis
%
% Output:
% -------
%   ix(npix,1)      Index array by which the pixels have been reordered
%                  i.e. u1(ix) gives the reordered values of u1
%   npix(nbin,1)    Number of contributing pixels to the bins in the Cartesian grid
%                  as a column vector. Bin indicies of reshaped Cartesian grid
%                  are numbered in the same sequence as would be returned by the
%                  matlab instrinsic sub2ind)
%   p               Cell array [1 x nd] of column vectors of bin boundaries
%                  in Cartesian grid
%   grid_size       Scalar or row vector (1xnd) of number of actual bins along each axis
%                  This may differ from the input grid_size if the range along any of the
%                  axes is zero: in this case the size of the grid along those axes = 1
%   ibin(npix,1)    Column vector with list of bins to which the sorted pixels contribute
%                  Available for convenience as it can be constructed from npix:
%                       ibin(1:nbin(1))=1
%                       ibin(nbin(1):nbin(2))=2
%                               :
%                       ibin(nbin(end-1):nbin(end))=length(nbin)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)


[nd,npixels] = size(u);    % no. dimensions and no. pixels
[grid_size,p]=construct_grid_size(grid_size_in,urange);

% Get bin index numbers for each array in turn (to minimise memory use)
% Account explicitly for case of only one bin along any dimension
ok=true(1,npixels);
for id=1:nd
    ok=ok & u(id,:)>=urange(1,id) & u(id,:)<=urange(2,id);
end
ibin=double(ok);            % fill with unity where the bins are OK
nel=[1,cumprod(grid_size)]; % Number of elements per unit step along each dimension
for id=find(grid_size>1)    % Only for those dimensions with more than one bin *** does the rest of the code work if ~any(ok)==1?
    ibin(ok) = ibin(ok) + nel(id)*max(0,min((grid_size(id)-1),floor(grid_size(id)*((u(id,ok)-urange(1,id))/(urange(2,id)-urange(1,id))))));
end

% Sort into increasing bin number and return indexing array
% (treat only the contributing pixels: if the the grid is much smaller than the extent of the data this will be faster)
ix=find(ok);                % Pixel indicies that are included in the grid
[ibin,ind]=sort(ibin(ok));  % ordered bin numbers of the included pixels with index array into the original list of bin numbers of included pixels
ix=ix(ind)';                % Indicies of included pixels coerresponding to ordered list; convert to column vector

ibin=ibin';
npix=accumarray(ibin,1,[prod(grid_size),1]);
