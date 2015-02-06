function [irange,inside,outside] = get_irange(urange,varargin)
% Get range of bin boundary indicies that intersect an n-dimensional rectange
%
%   >> irange = get_irange(urange,p1,p2,p3,...pnd)
%   >> [irange,inside,outside] = get_irange(urange,p1,p2,p3,...pnd)
%
% Works for an arbitrary number of dimensions ndim (ndim>0), and with
% non-uniformly spaced bin boundaries.
%
% Input:
% ------
%   urange  Range to cover: array size [2,ndim] of [urange_lo; urange_hi]
%          where ndim is the number of dimensions. It is required that
%          urange_lo <=urange_hi for each dimension
%   p1(:)   Bin boundaries along first axis
%   p2(:)   Similarly axis 2
%   p3(:)   Similarly axis 3
%    :              :
%           It is assumed that each array of bin boundaries has
%          at least two values (i.e. at least one bin), and that
%          the bin boundaries are monotonic increasing.
%
% Output:
% -------
%   irange  Bin index range: array size [2,ndim]. If the region defined by
%          urange lies fully outside the bins, then for at least one 
%          dimension index i the ranges will have irange(1,i)>irange(2,i).
%   inside  If the range defined by urange is fully contained within
%          the bin boundaries, then contained==true. Otherwise,
%          inside==false.
%   outside If the range defined by urange is fully outsie the bin
%          boundaries, then outside=true;


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


nd=numel(varargin);
if nd==0
    error('Must give bin boundary array(s)')
elseif size(urange,2)~=nd
    error('Check number of bin boundary arrays matches size of urange')
elseif any(urange(1,:)>urange(2,:))
    error('Must have urange_lo <= urange_hi for all dimensions')
end

irange = zeros(2,nd);
inside=true;
for id=1:nd
    blo = upper_index(varargin{id},urange(1,id));
    bhi = lower_index(varargin{id},urange(2,id));
    bmax=numel(varargin{id});
    irange(1,id) = max(1,blo);
    irange(2,id) = min(bmax,bhi)-1;
    if inside  && (blo==0 || bhi>bmax)   % section not within the input bins
        inside=false;
    end
end

if any(irange(1,:)>irange(2,:)) % section not in the input bins
    outside=true;
else
    outside=false;
end
