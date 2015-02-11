function [nstart,nend] = get_nrange_section (urange,nelmts,varargin)
% Get contiguous ranges of elements of an array where it intersects a hypercuboid
%
% Given an array containing number of points in bins, and the bin boundaries,
% return column vectors of the start and end indicies of ranges of contiguous
% points for those bins that partially or fully lie within a hypercuboid,
% n the column representation of the points.
%
%   >> [nstart,nend] = get_nrange (urange,nelmts,,p1,p2,p3...)
% 
% Input:
% ------
%   urange  Range to cover: 2 x ndim array of [urange_lo; urange_hi]
%   nelmts  Array of number of points in n-dimensional array of bins
%          e.g. 3x5x7 array such that nelmts(i,j,k) gives no. points in
%          the (i,j,k)th bin. If the number of dimensions defined by urange,
%          ndim=size(urange,2), is greater than the number of dimensions
%          defined by nelmts, n=numel(size(nelmts)), then the excess
%          dimensions required of nelmts are all assumed to be singleton
%          following the usual matlab convention.
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
%   nstart  Column vector of starting values of contiguous blocks in
%          the array of values with the number of elements in a bin
%          given by nelmts(:).
%   nend    Column vector of finishing values.
%
%           nstart and nend have column length zero if there are no
%          elements i.e. have the value zeros(0,1).


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Check input arguments
ndim=numel(varargin);
if ndim==0
    error('Must give bin boundary array(s)')
elseif numel(size(urange))~=2 || size(urange,1)~=2 || size(urange,2)~=ndim
    error('Check urange is a 2 x ndim array where ndim is the number of bin boundary arrays')
elseif any(urange(1,:)>urange(2,:))
    error('Must have urange_lo <= urange_hi for all dimensions')
end

sz = size(nelmts);
if isempty(nelmts)
    error('Number array ''nelmts'' cannot be empty')
elseif ~((ndim==1 && sz(2)==1) || ndim>=numel(sz))
    error('Size of number array ''nelmts'' is inconsistent with the number of bin boundary arrays')
end

% Get contiguous arrays
[irange,inside,outside] = get_irange(urange,varargin{:});
if ~outside
    [nstart,nend] = get_nrange(nelmts,irange);
else
    nstart=zeros(0,1);
    nend=zeros(0,1);
end
