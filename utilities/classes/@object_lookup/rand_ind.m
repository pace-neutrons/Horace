function X = rand_ind (obj, varargin)
% Generate random points for indexed occurences in an object lookup table
%
%   >> X = rand_ind (obj, iarray, ind)
%   >> X = rand_ind (obj, ind)
%
%   >> X = rand_ind (...,'options', p1, p2,...)
%
% The purpose is to return random points from a method of the form:
%       X = rand (object, sz)
%       X = rand (object, sz, p1, p2,...)
%
% for a set of objects defined by index arguments iarray and ind.
% 
%
% Input:
% ------
%   obj         object_lookup object
%
%   iarray      Scalar index of the original object array from the
%              cell array of object arrays from which the object lookup
%              was created.
%               If there was only one object array, then iarray is not
%              necessary (as it assumed iarray=1)
%
%   ind         Array containing indices of objects in the original
%              object array referred to by iarray, from which a random point
%              is to be taken. min(ind(:))>=1, max(ind(:))<=number of objects
%              in the object array selected by iarray
%
% Optionally:
%   'options', p1, p2...    Optional parameters to be passed to the rand
%                           function
%
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
%       >> X = rand (..., p1, p2, ...)      % with further optional arguments
%
%       Input:
%       ------
%       n           Return square array of random numbers with size n x n
%           *OR*
%       sz          Size of array of output array of random numbers
%           *OR*
%       sz1,sz2...  Extent along each dimension of random number array
%
%       p1, p2,...  Optional arguments. It is assumed that the method
%                   can resolve any ambiguities between p1 and n, sz or szn
%
%       Output:
%       -------
%       X           Array of random points. If the size of X for a single
%                   point is sz0, then the size of X is [sz0,sz] with any
%                   singleton dimensions in the size squeezed away.


% Check validity
if ~isscalar(obj)
    error('Only operates on a single object_lookup (i.e. object must be scalar');
end
if ~obj.filled
    error('The object_lookup is not initialised')
end

% Check input arguments
options = @(x)(is_string(x) && ~isempty(x) && strncmpi(x,'options',numel(x)));

if numel(varargin)>=3 && options(varargin{3})
    iarray = varargin{1};
    ind = varargin{2};
    args = varargin(4:end);
elseif numel(varargin)>=2 && options(varargin{2})
    iarray = 1;
    ind = varargin{1};
    args = varargin(3:end);
elseif numel(varargin)<=2
    if numel(varargin)==1
        iarray = 1;
        ind = varargin{1};
    else
        iarray = varargin{1};
        ind = varargin{2};
    end
    args = cell(1,0);   % assumes the input is ind, or iarray and ind
else
    error('Check the number and type of input options')
end

X = rand_ind_private (obj.object_store_, obj.indx_{iarray}(ind), args{:});



%------------------------------------------------------------------
function X = rand_ind_private (obj, ind, varargin)
% Given a list of indices, find location and number of unique occurences
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
%       >> X = rand (..., p1, p2, ...)      % further optional arguments
%
%       Input:
%       ------
%       n           Return square array of random numbers with size n x n
%           *OR*
%       sz          Size of array of output array of random numbers
%           *OR*
%       sz1,sz2...  Extent along each dimension of random number array
%
%       p1, p2,...  Optional arguments. It is assumed that the method
%                   can resolve any ambiguities between p1 and n, sz or szn
%
%       Output:
%       -------
%       X           Array of random points.If the size of X for a single
%                   point is sz1, then the size of X is [sz1,sz] with any
%                   singleton dimensions in the size squeezed away.


if issorted(ind(:))
    if ind(1)~=ind(end)
        B = ind(:);
        ix = [];    % empty will indicate that no reordering is needed later
    else
        X = obj(ind(1)).rand(size(ind),varargin{:});    % all ind(:) are the same
        return
    end
else
    [B,ix] = sort(ind(:));
end
nend = [find(diff(B));numel(B)];
nbeg = 1+[0;nend(1:end-1)];
nelmt = nend-nbeg+1;

indu = B(nbeg);     % unique index numbers
sz = size(obj(indu(1)).rand(1),varargin{:});    % size of random array returned by object rand method

X = NaN(prod(sz),nend(end));
for i=1:numel(indu)
    X(:,nbeg(i):nend(i)) = obj(indu(i)).rand(nelmt(i),1,varargin{:});
end
if ~isempty(ix)
    X(:,ix) = X;
end
X = squeeze(reshape(X,[sz,size(ind)]));
