function [nstart,nend] = get_nrange_rot_section (urange,rot,trans,nelmts,varargin)
% Get indicies that define ranges of contiguous elements from an n-dimensional
% array of bins of elements, where the bins partially or wholly lie
% inside a hypercuboid volume that on the first three axes can be rotated and
% translated w.r.t. to the hypercuboid that is split into bins.
%
%   >> [nstart,nend] = get_nrange (urange,rot,trans,nelmts,p1,p2,p3,...)
% 
% Input:
% ------
%   urange  Range to cover: 2 x n array of upper and lower limits
%          [urange_lo; urange_hi] (in units of a coordinate frame
%          that is rotated shifted with respect to that frame in
%          which the bin boundaries p1,p2,p3 are expressed, see below)
%   rot     Matrix, A     --|  that relate the two coordinate frames
%   trans   Translation, T--|  of the bin boundary arrays and of urange:
%              r'(i) = A(i,j)(r(j) - T(j))
%          where r(j) are the coordinates of a vector in the frame of the
%          bin boundaries p1,p2,p3 (below), and r'(i) are the coordinates
%          of the frame in which urange is expressed.
%           Note that T is given in coordinates of the axes of the bin
%          boundaries.
%   nelmts  Array of number of points in n-dimensional array of bins
%          e.g. 3x5x7 array such that nelmts(i,j,k) gives no. points in (i,j,k)th bin
%   p1(:)   Bin boundaries along first axis (column vector)
%   p2(:)   Similarly axis 2
%   p3(:)   Similarly axis 3
%    :              :
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
%
% Output will not necessarily be strictly contiguous blocks, as the routine
% handles the first three dimensions separately from the following ones. The
% blocks are contiguous within the first three dimensions, however.
% This should be straightforward to improve, following the algorithm of
% get_nrange


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Default return values
nstart=zeros(0,1);
nend=zeros(0,1);

% Check number of input arguments
nd=numel(varargin);
if nd<3; error('Must have at least three dimensions'); end
nbin=zeros(1,nd);
for i=1:nd
    nbin(i)=numel(varargin{i})-1;
end
if any(nbin<1)
    error('Must have at least one bin along each axis')
end

% Check consistency of lengths of p arrays and size of nelmts
dims = size(nelmts);
ndim = numel(dims);
if ndim<3
    error('Array ''nelmts'' must have at least three dimensions')
elseif ~( (ndim<nd && all(nbin(1,ndim+1:nd)==1) && all(nbin(2,ndim+1:nd)==1)) || ... % allow for outer p{i} being singleton dimensions
      (ndim==nd && all(nbin==dims)) )
    error('Dimensions of number array and number and/or length of bin boundary arrays inconsistent')
end

% Check dimensions of ranges and bin boundaries are consistent
if size(urange,2)~=ndim
    error('Dimension of range and number of bin boundaries arrays are inconsistent')
elseif any(urange(1,:)>urange(2,:))
    error('Must have urange_lo <= urange_hi for all dimensions')
end

if ndim>3
    % Check first if the simple section of dimensions 4,5,... leaves any points (as fast to test)
    [irange,inside,outside] = get_irange(urange(:,4:end),varargin{4:ndim});
    if outside; return; end
    irangecell=cell(1,ndim-2);  % one cell for the first three dimensions
    for i=4:ndim
        irangecell{i-2} = irange(1,i-3):irange(2,i-3);
    end
    % Get index ranges for column representation for first three axes
    [istart,iend] = get_irange_rot(urange,rot,trans,varargin{1:3});
    if isempty(istart); return; end
    % Get contiguous blocks for the whole array
    ncum=cumsum(nelmts(:));
    ncum = reshape (ncum,[prod(dims(1:3)),dims(4:end)]);
    nelmts = reshape (nelmts,[prod(dims(1:3)),dims(4:end)]);
    irangecell{1}=istart;
    nstart = ncum(irangecell{:})-nelmts(irangecell{:})+1;
    nstart = nstart(:);
    irangecell{1}=iend;
    nend   = ncum(irangecell{:});
    nend   = nend(:);
else
    % Get index ranges for column representation for first three axes
    [istart,iend] = get_irange_rot(urange,rot,trans,varargin{1:3});
    if isempty(istart); return; end
    ncum=cumsum(nelmts(:));
    nstart = ncum(istart)-nelmts(istart)+1;
    nend   = ncum(iend);
end

% Must account for the cases where there were no elements in a bin:
% [The algorithm
%     nstart = ncum(istart)-nelmts(istart)+1;
%     nend   = ncum(iend);
% only works if there is at least one element in the bin; otherwise nend<nstart]
ok = (nend-nstart>=0);
nstart=nstart(ok);
nend=nend(ok);
