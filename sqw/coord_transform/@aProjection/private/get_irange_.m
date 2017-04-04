function [irange,inside,outside] = get_irange_(urange,varargin)
% Get ranges of bins that partially or wholly lie inside an n-dimensional rectangle
%
%   >> irange = get_irange(urange,p1,p2,p3,...pndim)
%   >> [irange,inside,outside] = get_irange(urange,p1,p2,p3,...pndim)
%
% Works for an arbitrary number of dimensions ndim (ndim>0), and with
% non-uniformly spaced bin boundaries.
%
% Input:
% ------
%   urange  Range to cover: array size [2,ndim] of [urange_lo; urange_hi]
%          where ndim is the number of dimensions. It is required that
%          urange_lo <=urange_hi for each dimension
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
%          urange lies fully outside the bins, then irange is set to zeros(0,ndim)
%          i.e. isempty(irange)==true.
%   inside  If the range defined by urange is fully contained within
%          the bin boundaries, then contained==true. Otherwise,
%          inside==false.
%   outside If the range defined by urange is fully outside the bin
%          boundaries i.e. there is no interstcion of the two volumes,
%          then outside=true;


% Original author: T.G.Perring
%
% $Revision: 1170 $ ($Date: 2016-02-01 17:35:02 +0000 (Mon, 01 Feb 2016) $)


ndim=numel(varargin);
if ndim==0
    error('Must give bin boundary array(s)')
elseif numel(size(urange))~=2 || size(urange,1)~=2 || size(urange,2)~=ndim
    error('Check urange is a 2 x ndim array where ndim is the number of bin boundary arrays')
elseif any(urange(1,:)>urange(2,:))
    error('Must have urange_lo <= urange_hi for all dimensions')
end

irange = zeros(2,ndim);
inside=true;
outside=false;
for idim=1:ndim
    blo = upper_index(varargin{idim},urange(1,idim));
    bhi = lower_index(varargin{idim},urange(2,idim));
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
