function [irange,inside,outside] = get_irange_(img_db_range,varargin)
% Get ranges of bins that partially or wholly lie inside an n-dimensional rectangle
%
%   >> irange = get_irange(pix_range,p1,p2,p3,...pndim)
%   >> [irange,inside,outside] = get_irange(pix_range,p1,p2,p3,...pndim)
%
% Works for an arbitrary number of dimensions ndim (ndim>0), and with
% non-uniformly spaced bin boundaries.
%
% Input:
% ------
%   pix_range  Range to cover: array size [2,ndim] of [pix_range_lo; pix_range_hi]
%          where ndim is the number of dimensions. It is required that
%          pix_range_lo <=pix_range_hi for each dimension
%   p1      Bin boundaries along first axis (column vector)
%   p2      Similarly axis 2
%   p3      Similarly axis 3
%    :              :
%   pndim   Similarly axis ndim
%           It is assumed that each array of bin boundaries has
%          at least two values (i.e. at least one bin), and that
%          the bin boundaries are monotonic increasing.
%
% Output:
% -------
%   irange  Bin index range: array size [2,ndim]. If the region defined by
%          pix_range lies fully outside the bins, then irange is set to zeros(0,ndim)
%          i.e. isempty(irange)==true.
%   inside  If the range defined by pix_range is fully contained within
%          the bin boundaries, then contained==true. Otherwise,
%          inside==false.
%   outside If the range defined by pix_range is fully outside the bin
%          boundaries i.e. there is no interstcion of the two volumes,
%          then outside=true;


% Original author: T.G.Perring
%


ndim=numel(varargin);
if ndim==0
    error('Must give bin boundary array(s)')
elseif numel(size(img_db_range))~=2 || size(img_db_range,1)~=2 || size(img_db_range,2)~=ndim
    error('Check pix_range is a 2 x ndim array where ndim is the number of bin boundary arrays')
elseif any(img_db_range(1,:)>img_db_range(2,:))
    error('Must have pix_range_lo <= pix_range_hi for all dimensions')
end

irange = zeros(2,ndim);
inside=true;
outside=false;
for idim=1:ndim
    blo = upper_index(varargin{idim},img_db_range(1,idim));
    bhi = lower_index(varargin{idim},img_db_range(2,idim));
    bmax=numel(varargin{idim});
    irange(1,idim) = max(1,blo);
    irange(2,idim) = min(bmax,bhi)-1;
    if inside  && (blo==0 || bhi>bmax)   % section not within the input bins
        inside=false;
    end
end

if any(irange(1,:)>irange(2,:)) % section not in the input bins
    irange=zeros(0,ndim);
    outside=true;
end

