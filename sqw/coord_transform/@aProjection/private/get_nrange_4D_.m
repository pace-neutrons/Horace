function [nstart,nend] = get_nrange_4D_(nelmts,istart,iend,irange)
% Get contiguous ranges of an array for a section of the binning array
%
% Given an array containing number of points in bins, contiguous bin ranges
% for the first three dimensions and a section of the array for the
% remaining dimensions, return column vectors of the start and end indices of
% ranges of contiguous points in the column representation of the points.
% Works for any dimensionality 3,4,...
%
%   >> [nstart,nend] = get_nrange(nelmts,irange)
%
% Input:
% ------
%   nelmts      Array of number of points in n-dimensional array of bins
%              e.g. 3x5x7 array such that nelmts(i,j,k) gives no. points in
%              the (i,j,k)th bin. If the number of dimensions defined by irange,
%              ndim=size(irange,2), is greater than the number of dimensions
%              defined by nelmts, n=numel(size(nelmts)), then the excess
%              dimensions required of nelmts are all assumed to be singleton
%              following the usual Matlab convention.
%   istart      Column vector of indices of the start of contiguous ranges
%              within the first three dimensions.
%   iend        Column vector of indices of the end of contiguous ranges
%              within the first three dimensions.
%   irange      Ranges of section [irange_lo;irange_hi] for the 4th and higher
%              dimensions e.g. [1,2,6;3,4,7] means bins 1:3, 2:4, 6:7 along
%              the 3rd,4th,5th axes. Assumes irange_lo<=irange_hi. If only
%              three axes, then irange should be empty.
%
% Output:
% -------
%   nstart      Column vector of starting values of contiguous blocks in
%              the array of values with the number of elements in a bin
%              given by nelmts(:).
%   nend        Column vector of finishing values.
%
%               nstart and nend have column length zero if there are no
%              elements i.e. have the value zeros(0,1).


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Get number of dimensions and check consistency
if isempty(istart)||numel(istart)~=numel(iend)
    error('Must have at least one range of bins in the first three dimensions')
elseif ~(iscolvector(istart) || iscolvector(iend))
    error('istart and iend must be column vectors')
elseif any(istart<1) || any(iend<istart)
    error('Must have istart<=iend for each range')
elseif any(iend(1:end-1)>=istart(2:end))
    error('At least one range defined by istart and iend overlaps with another')
end

if isempty(irange)
    nd=3;   % empty irange necessarily implies three dimensions
else
    sz = size(irange);
    if numel(sz)~=2 || sz(1)~=2 || any(irange(1,:))<1 || any(irange(2,:)<irange(1,:))
        error('irange must be a 2 x n array (n>0), of ranges')
    end
    nd=sz(2)+3;
end

dims = size(nelmts);
ndim = numel(dims);
if isempty(nelmts)
    error('Number array cannot be empty')
elseif ~(ndim==nd || (ndim<nd && ...
        (ndim<=3 && (nd==3 || (nd>3 && all(irange(1,:)==1) && all(irange(2,:)==1))) ||...
        (ndim>3  && all(irange(1,end-(nd-ndim-1):end)==1) && all(irange(2,ndim+1:end)==1)))))
    % note, excess dimensions in irange corresponding to singletons are ignored
    error('Dimensions of number array inconsistent with indexing of subsection')
end
if prod(dims(1:min(3,ndim)))<iend(end)
    error('Ranges of indices in first three dimensions exceeds that of the array ''nelmts''')
end
if ndim>3 && any(dims(4:end)<irange(2,1:ndim-3))
    error('Range(s) in ''irange'' must lie within the corresponding dimensions of the array ''nelmts''')
end

% Get contiguous ranges
% (At this point, we have ndim as the relevant number of dimensions, all trailing singletons in irange dropped)
if ndim>3 && (numel(istart)==1 && istart(1)==1 && iend(1)==prod(dims(1:3)))
    % All bins in inner three dimensions are retained, and at least one extra dimension
    irange3D=[ones(1,3);dims(1:3)];
    [nstart,nend] = aProjection.get_nrange(nelmts,[irange3D,irange]);
else
    if ndim>3
        % Limited number of bins from inner three dimensions, and at least one extra dimension
        % Note: if istart(1)=1 and iend(end)=prod(dims(1:3)) but numel(istart)>1 then
        % the last range of bins in the third dimension will be contiguous with the first range
        % for the next increment in the fourth dimension. The following algorithm does not
        % catch that case as being a single contiguous range. Therefore the algorithm
        % does not guarantee non-contiguity of the output nstart and nend arrays.
        irangecell=cell(1,ndim-2);  % one cell for the first three dimensions
        for i=4:ndim
            irangecell{i-2} = irange(1,i-3):irange(2,i-3);
        end
        % Get contiguous blocks for the whole array
        ncum = reshape (cumsum(nelmts(:)),[prod(dims(1:3)),dims(4:end)]);
        nelmts = reshape (nelmts,[prod(dims(1:3)),dims(4:end)]);
        irangecell{1}=istart;
        nstart = ncum(irangecell{:})-nelmts(irangecell{:})+1;
        nstart = nstart(:);
        irangecell{1}=iend;
        nend   = ncum(irangecell{:});
        nend   = nend(:);
    else
        % Three or fewer dimensions in nelmts
        % istart, iend already give contiguous ranges for the first three dimensions, by assumption
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
end
