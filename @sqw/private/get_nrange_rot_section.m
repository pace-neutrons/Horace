function [nstart,nend] = get_nrange_rot_section (urange,rot,trans,nelmts,varargin)
% Get indicies that define ranges of contiguous elements from an n-dimensional
% array of bins of elements, where the bins partially or wholly lie
% inside a hypercuboid volume that on the first three axes can be rotated and
% translated w.r.t. to the hypercuboid that is split into bins.
%
% Output will not necessarily be strictly contiguous blocks, as the routine handles the first
% three dimensions separately from the following ones. The blocks are contiguous within
% the first three dimensions, however.
%
%   >> [nstart,nend] = get_nrange (urange,rot,trans,nelmts,,p1,p2,p3,...)
% 
% Input:
%   urange(2,n)     Range to cover: 2 x n array of [urange_lo; urange_hi]
%   rot             Matrix [3x3]     --|  that relate a vector expressed in the
%   trans           Translation [3x1]--|  frame of the bin boundaries to those of urange:
%                                             r'(i) = A(i,j)(r(j) - trans(j))
%                                  (trans is the vector from the origin of the frame
%                                   in which the bins are expressed to that in which
%                                   urange is expressed)
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

% Default return values
nstart=[];
nend=[];

% Check number of input arguments
ndim=length(varargin);
if ndim<3; error('Must have at least three dimensions'); end
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
    error('Dimensions of number array and bin boundaries inconsistent')
end

if ndim>3
    % Check first if the simple section of dimensions 4,5,... leaves any points (as fast to test)
    irange = get_irange(urange(:,4:end),varargin{4:end});
    if isempty(irange); return; end
    irangecell=cell(1,ndim-2);  % one cell for the first three dimensions
    for i=4:ndim
        irangecell{i-2} = irange(1,i-3):irange(2,i-3);
    end
    % Get index ranges for column representation for first three axes
    [istart,iend] = get_irange_rot(urange,rot,trans,varargin{1:3});
    if isempty(iend)    % iend is empty when hdf used too. 
        if isempty(istart), return, end; 
        % *** works in 4D only!!! 
        length3d = prod(dims(1:3));
        ind4     = (irange(1):irange(2))-1;              
        selection= numel(ind4)*numel(istart);
        ind = zeros(selection,2);
        ind(:,1) = reshape(repmat(istart,[1,numel(ind4)]),1,selection);
        ind(:,2) = reshape(ind4(ones(1,numel(istart)),:),1,selection);
        nstart   = ind(:,2)*length3d+ind(:,1);
        clear ind;
        return;                      % but then istart would have pixel information
    end 
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
    if isempty(iend); nstart=istart; 
        return; 
    end % iend is empty when hdf used too.
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
