function [nstart,nend] = get_nrange_(nelmts,irange)
% Get contiguous ranges of an array for a section of the binning array
%
% Given an array containing number of points in bins, and a section of
% that array, return column vectors of the start and end indicies of
% ranges of contiguous points in the column representation of the points.
% Works for any dimensionality 1,2,...
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
%              following the usual matlab convention.
%   irange      Ranges of section [irange_lo;irange_hi]
%              e.g. [1,2,6;3,4,7] means bins 1:3, 2:4, 6:7 along the three
%              axes. Assumes irange_lo<=irange_hi.
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
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)


% Get number of dimensions and check consistency
sz = size(irange);
if numel(sz)~=2 || sz(1)~=2 || sz(2)==0 || any(irange(1,:))<1 || any(irange(2,:)<irange(1,:))
    error('irange must be a 2 x n array (n>0), of ranges')
end
nd=sz(2);

dims = size(nelmts);
ndim = numel(dims);
if isempty(nelmts)
    error('Number array cannot be empty')
elseif ndim==2 && dims(2)==1 && nd==1
    dims=dims(1:end-1); % treat as case of a column vector
    ndim=1;
elseif ~(ndim==nd || (ndim<nd && all(irange(1,ndim+1:end)==1) && all(irange(2,ndim+1:end)==1)))
                        % note, excess dimensions in irange corresponding to singletons are ignored
    error('Dimensions of number array inconsistent with indexing of subsection')
end
if any(dims<irange(2,:))
    error('Ranges must lie within the dimensions of the array')
end 

% Get contiguous ranges
% (At this point, we have ndim as the relevant number of dimensions, all trailing singletons in irange dropped)
full_dim = all(irange(:,1:ndim)==[ones(1,ndim);dims],1);  % ith element = 1 if irange(:,i)==[1;dims(i)]
ind = find(~full_dim);
if isempty(ind) % all dimensions run over full ranges
    nstart = 1;
    nend = sum(nelmts(:));
else
    ncum = cumsum(nelmts(:));
    idim = ind(1);  % first dimension which has restricted range of indices
    % Get the size of the contiguous block, expressed as indicies in the flattening of first idim dimensions
    istart = 1+(irange(1,idim)-1)*prod(dims(1:idim-1)); % relies on prod of an array size [1,0] is unity
    iend   =       irange(2,idim)*prod(dims(1:idim-1)); % ditto
    if idim==ndim
        % First dimension with restricted range is the outer dimension
        nstart=ncum(istart)-nelmts(istart)+1;
        nend  =ncum(iend);
    else
        % Construct cell array of the indicies along the remaining dimensions
        % (this is a trick to pass an unknown number of arguments to the matlab function to get an array subsection)
        irangecell = cell(1,ndim-idim);
        for i=idim+1:ndim
            irangecell{i-idim}=irange(1,i):irange(2,i);
        end
        ncum   = reshape(ncum,[prod(dims(1:idim)),dims(idim+1:ndim)]);
        nelmts = reshape(nelmts,[prod(dims(1:idim)),dims(idim+1:ndim)]);
        nstart = ncum(istart,irangecell{:}) - nelmts(istart,irangecell{:}) + 1;
        nend   = ncum(iend,irangecell{:});
        nstart = nstart(:);
        nend   = nend(:);
    end
end

% Must account for the cases where there were no elements in a bin:
% [The algorithm
%     nstart = ncum(istart)-nelmts(istart)+1;
%     nend   = ncum(iend);
% only works if there is at least one element in the bin; otherwise nend<nstart]
ok = (nend-nstart>=0);
nstart=nstart(ok);
nend=nend(ok);

