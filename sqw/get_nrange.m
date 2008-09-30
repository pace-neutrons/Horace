function [nstart,nend] = get_nrange(nelmts,irange)
% Given an array containing number of points in bins, and a section of
% that array, return column vectors of start and end indicies of contiguous points
% in the column representation of the points.
% Works for any dimensionality 1,2,...
%
%   >> [nstart,nend] = get_nrange(nelmts,irange)
%
% Input:
%   nelmts      Array of number of points in n-dimensional array of bins
%              e.g. 3x5x7 array such that nelmts(i,j,k) gives no. points in (i,j,k)th bin
%   irange      Ranges of section [irange_lo;irange_hi] (assumes irange_lo<=irange_hi)
%              e.g. [1,2,6;3,4,7] means bins 1:3, 2:4, 6:7 along the three axes
% Output:
%   nstart      Array of starting values of contiguous block in nelmts(:)
%   nend        Array of finishing values
%               nstart=nend=[] if there are no elements

% T.G.Perring   01/07/2007

% Get number of dimensions and check consistency
ndim = size(irange,2);
dims = size(nelmts);
if length(dims)==2 && dims(2)==1 && ndim==1         % Account for case of a column vector
    dims=dims(1:end-1);
elseif length(dims)<ndim && all(diff(irange(:,length(dims)+1:end))==0)    % Account for excess dimensions in irange being singletons
    dims=[dims,ones(1,ndim-length(dims))];
elseif length(dims)~=ndim
    error('dimensions of number array inconsistent with indexing of subsection')
end

ncum = cumsum(nelmts(:));
full_dim = all(irange==[ones(1,length(dims));dims],1);  % ith element = 1 if irange(:,i)==[1;dims(i)]
ind = find(full_dim==0);
if isempty(ind) % all dimensions run over full range
    nstart = 1;
    nend = ncum(end);
else
    idim = ind(1);  % first dimension which has restricted range of indices
    % Get the size of the contiguous block, expressed as indicies in the flattening of first idim dimensions
    istart = 1+(irange(1,idim)-1)*prod(dims(1:idim-1)); % relies on prod of an empty array being = 1
    iend   =       irange(2,idim)*prod(dims(1:idim-1)); % ditto
    if idim==ndim
        nstart=istart;
        nend  =iend;
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
