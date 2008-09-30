function [nstart,nend] = get_nrange_section (urange,nelmts,varargin)
% Get contiguous ranges of elements from a subsection of an n-dimensional array
%
%   >> [nstart,nend] = get_nrange (urange,nelmts,,p1,p2,p3...)
% 
% Input:
%   urange(2,nd)    Range to cover: 2 x nd array of [urange_lo; urange_hi]
%   nelmts          Array of number of points in n-dimensional array of bins
%                       e.g. 3x5x7 array such that nelmts(i,j,k) gives no. points in (i,j,k)th bin
%   p1(:)           Bin boundaries along first axis
%   p2(:)           Similarly axis 2
%   p3(:)           Similarly axis 3
%    :                      :
%   
% Output:
%   nstart          Array of starting values of contiguous block in nelmts(:)
%   nend            Array of finishing values
%
%   If the region defined by urange lies outside the bins, or there are no elements in the range (i.e. the
%   bins that are in the range contain no elements) then nstart and nend returned as empty array [].

% T.G.Perring 03/07/2007

% Check number of input arguments
ndim=length(varargin);
dims=zeros(1,ndim);
for i=1:ndim
    dims(i)=length(varargin{i})-1;
end

% Check dimensions of ranges and bin boundaries are consistent
if size(urange,2)~=ndim
    error('Dimension of range and number of bin boundaries arrays are inconsistent')
end

% Check consistency of lengths of p arrays and size of nelmts
dims_nelmts = size(nelmts);
ndim_nelmts = length(dims_nelmts);
if ~( (ndim_nelmts<ndim && all(dims(ndim_nelmts+1:ndim)==1)) || ... % allow for outer p{i} being singleton dimensions
      (ndim_nelmts==ndim && all(dims==dims_nelmts)) )
    error('Dimensions of number array and lengths of bin boundaries inconsistent')
end

% Get contiguous arrays
irange = get_irange(urange,varargin{:});
if ~isempty(irange)
    [nstart,nend] = get_nrange(nelmts,irange);
else
    nstart=[];
    nend=[];
end
