function [nstart,nend] = get_nbin_range(this,npix)
% Get indices that define ranges of contiguous elements from an n-dimensional
% array of bins of elements, where the bins partially or wholly lie
% inside a hypersphere volume that on the first three axes can be transformed and
% translated w.r.t. to the hypercuboid that is split into bins.
%
%   >> [nstart,nend] = this.get_nrange_proj_section(pix_range,nelmts,p1,p2,p3,...)
%
% Input:
% ------
%   pix_range  Range to cover: 2 x ndim (ndim>=3) array of upper and lower limits
%          [pix_range_lo; pix_range_hi] (in units of a coordinate frame
%          that is rotated and shifted with respect to that frame in
%          which the bin boundaries p1,p2,p3 are expressed, see below)
%
%
%
% Output:
% -------
%   nstart  Column vector of starting values of contiguous blocks in
%          the array of values with the number of elements in a bin
%          given by nelmts(:).
%   nend    Column vector of finishing values.
%
%           nstart and nend have column length zero if there are no
%          elements i.e. have the value zeros(0,1).


% Original author: T.G.Perring
%
%

% pixels on the boundary because of rounding errors in get_nrange_rot_section
if isempty(npix)
    error('Number array ''npix'' cannot be empty')
end

img_db_range = range_add_border(this.new_img_db_range_,data_sqw_dnd.border_size);

[nbin_in,pin]  = this.get_input_data_binning_();
%
%   nelmts  Array of number of points in n-dimensional array of bins
%          e.g. 3x5x7 array such that nelmts(i,j,k) gives no. points in
%          (i,j,k)th bin. If the number of dimensions defined by pix_range,
%          ndim=size(pix_range,2), is greater than the number of dimensions
%          defined by nelmts, n=numel(size(nelmts)), then the excess
%          dimensions required of nelmts are all assumed to be singleton
%          following the usual Matlab convention.
nelmts = reshape(npix,nbin_in);

% Get contiguous arrays
[istart,iend,irange,inside,outside] = this.get_irange_proj(img_db_range,pin{:});
if ~outside
    [nstart,nend] = aProjection.get_nrange_4D(nelmts,istart,iend,irange);
else
    nstart=zeros(0,1);
    nend=zeros(0,1);
end

