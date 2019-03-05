function X = rand_ind (this, varargin)
% Generate random points for indexed occurences in an object lookup
%
%   >> X = rand_ind (this, iarray, ind)
%   >> X = rand_ind (this, ind)
%
% The purpose is to return random points from a function of the form:
%       X = rand (object)
%
% for a set of objects defined by index arguments iarray and ind.
% 
%
% Input:
% ------
%   this        object_lookup object
%
%   iarray      Scalar index of the original object array from the
%              cell array of object arrays from which the object lookup
%              was created.
%               If there was only one object array, then iarray is not
%              necessary (as it assumed iarray=1)
%
%   ind         Array containing indicies of objects in the original
%              object array referred to by iarray, from which a random point
%              is to be taken. min(ind(:))>=1, max(ind(:))<=number of objects
%              in the object array selected by iarray
%
% Output:
% -------
%   X           Array of random points. If the size of X for a single
%               point is sz1, then the size of X is [sz1,size(ind)] with any
%               singleton dimensions in the size squeezed away
%
%
% Requires a method with name rand to exist for the object, and which has
% the I/O as follows:
%
%       >> X = rand (object)                % generate a single random point
%       >> X = rand (object, n)             % n x n matrix of random points
%       >> X = rand (object, sz)            % array of size sz
%       >> X = rand (object, sz1, sz2,...)  % array of size [sz1,sz2,...]
%
%       Input:
%       ------
%       n           Return square array of random numbers with size n x n
%           *OR*
%       sz          Size of array of output array of random numbers
%           *OR*
%       sz1,sz2...  Extent along each dimension of random number array
%
% Output:
% -------
%       X           Array of random points. If the size of X for a single
%                   point is sz1, then the size of X is [sz1,sz] with any
%                   singleton dimensions in the size squeezed away.


if numel(varargin)==2
    iarray = varargin{1};
    if ~isscalar(iarray)
        error('Index to original object array, ''iarray'', must be a scalar')
    end
    ind = varargin{2};
elseif numel(varargin)==1
    if numel(this.indx_)==1
        iarray = 1;
        ind = varargin{1};
    else
        error('Must give index to the object array from which samples are to be drawn')
    end
else
    error('Insufficient number of input arguments')
end

X = rand_ind_private (this.object_array_, this.indx_{iarray}(ind));



%------------------------------------------------------------------
function X = rand_ind_private (obj, ind)
% Given a list of indicies, find location and number of unique occurences
%
%   >> X = rand_ind_private (obj, ind)
%
%
%
% Requires a method with name rand to exist for the object, and which has
% the I/O as follows:
%
%       >> X = rand (object)                % generate a single random point
%       >> X = rand (object, n)             % n x n matrix of random points
%       >> X = rand (object, sz)            % array of size sz
%       >> X = rand (object, sz1, sz2,...)  % array of size [sz1,sz2,...]
%
%       Input:
%       ------
%       n           Return square array of random numbers with size n x n
%           *OR*
%       sz          Size of array of output array of random numbers
%           *OR*
%       sz1,sz2...  Extent along each dimension of random number array
%
% Output:
% -------
%       X           Array of random points.If the size of X for a single
%                   point is sz1, then the size of X is [sz1,sz] with any
%                   singleton dimensions in the size squeezed away.


if issorted(ind(:))
    if ind(1)~=ind(end)
        B = ind(:);
        ix = [];    % empty will indicate that no reordering is needed later
    else
        X = obj(ind(1)).rand(size(ind));    % all ind(:) are the same
        return
    end
else
    [B,ix] = sort(ind(:));
end
nend = [find(diff(B));numel(B)];
nbeg = 1+[0;nend(1:end-1)];
nelmt = nend-nbeg+1;

indu = B(nbeg);     % unique index numbers
sz = size(obj(indu(1)).rand(1));    % size of random array returned by object rand method

X = NaN(prod(sz),nend(end));
for i=1:numel(indu)
    X(:,nbeg(i):nend(i)) = obj(indu(i)).rand(nelmt(i),1);
end
if ~isempty(ix)
    X(:,ix) = X;
end
X = squeeze(reshape(X,[sz,size(ind)]));
