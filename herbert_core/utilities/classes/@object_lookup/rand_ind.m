function X = rand_ind (obj, iarray, varargin)
% Generate random points for indexed occurences in an object lookup table
%
%   >> [X1, X2,...] = rand_ind (obj, iarray, ind, randfunc)
%   >> [X1, X2,...] = rand_ind (obj, iarray, ind, ielmts, randfunc)
%
%   >> [X1, X2,...]X = rand_ind (..., randfunc, p1, p2, ...)
%
%   >> [X1, X2,...] = rand_ind (..., 'split', randfunc, p1, p2, ...)
%   >> [X1, X2,...] = rand_ind (..., 'split', iargs, randfunc, p1, p2, ...)
%
% The purpose is to return random points for a set of objects defined by
% index arguments iarray and ind from a random sampling method of the form:
%
%   [X1, X2,...] = randfunc (object)               % generate a single random point
%   [X1, X2,...] = randfunc (object, n)            % n x n matrix of random points
%   [X1, X2,...] = randfunc (object, sz)           % array of size sz
%   [X1, X2,...] = randfunc (object, sz1, sz2,...) % array of size [sz1,sz2,...]
%
%   [X1, X2,...] = randfunc (..., p1, p2, ...)     % with further optional arguments
%
% If particular elements of the objects are selected by the input argument
% ielmts, then the form must be
%
%   [X1, X2,...] = randfunc (object, ielmts)
%   [X1, X2,...] = randfunc (object, ielmts, p1, p2, ...)
%
% See below for further details.
%
%
% Input:
% ------
%   obj         object_lookup object
%
%   iarray      Scalar index of the original object array from the
%              cell array of object arrays from which the object lookup
%              was created.
%
%   ind         Array containing indices of objects in the original
%              object array referred to by iarray, from which a random point
%              is to be taken. min(ind(:))>=1, max(ind(:))<=number of objects
%              in the object array selected by iarray
%
%   ielmts      [Optional] Array the same size as input argument ind that
%              gives the index of elements within the object identified by
%              ind.
%
%   randfunc    Handle to random sampling function. Must have one of the forms:
%
%               - If ielmts not present:
%       [X1, X2,...] = randfunc (object)               % generate a single random point
%       [X1, X2,...] = randfunc (object, n)            % n x n matrix of random points
%       [X1, X2,...] = randfunc (object, sz)           % array of size sz
%       [X1, X2,...] = randfunc (object, sz1, sz2,...) % array of size [sz1,sz2,...]
%       [X1, X2,...] = randfunc (..., p1, p2, ...)     % with further optional arguments
%                           % It is assumed that the method can resolve any ambiguities
%                           % between p1 and n, sz or szn
%
%               - If ielmts is present:
%       [X1, X2,...] = randfunc (object, ielmts)
%       [X1, X2,...] = randfunc (object, ielmts, p1, p2, ...)
%
% Optionally:
%   p1, p2...   Parameters to be passed to the random sampling function
%
%   'split'     Interpret each parameter p1, p2,... to be split into a stack
%              of arrays, the outer dimensions matching the dimensions of
%              ind (and ielmts if present), and the inner dimensions as those
%              of a parameter for a particular value of ind (and ielmts)
%
%   'split', iargs  Split only those argument p1, p2, p3... that are indicated
%                  by the integers in argument iargs. The others are assumed
%                  to apply in their entirety to all of ind (and ielmts).
%
%
% Output:
% -------
%   X1, X2,...  Arrays of random points. The output arrays for each value of
%               ind are stacked. For example, if the size of X1 for a single
%               call to randfunc is sz1, then the size of X1 returned by
%               rand_ind is [sz1,size(ind)] but with leading singleton
%               dimensions in size(ind) used to hold trailing dimensions of
%               sz1.
%
%               Note the output array size is not necessarily the same as
%               that obtained by using the matlab intrinsic function squeeze.
%
%               See also size_array_stack for details
%
%               EXAMPLES
%                   randfunc output      size(ind)        size(X1)
%                       [1,3]               [1,5]           [1,3,5]
%                       [3,1]               [1,5]           [3,5]
%                       [3,1]               [1,1,5]         [3,1,5]


% Check validity
if ~isscalar(obj)
    error('Only operates on a single object_lookup object (i.e. must be scalar');
end
if ~obj.filled
    error('The object_lookup is not initialised')
end

% Parse the input arguments
[ind, ielmts, randfunc, args, split] = parse_args_rand_ind (varargin{:});

% Create an array of indicies to the unique objects stored in obj,
% corresponding to the input index array ind
ind_unique_obj = reshape (obj.indx_{iarray}(ind), size(ind));   % retain shape of ind

% Call a private function that efficiently randomly samples the objects
X = rand_ind_private (obj.object_store_, ind_unique_obj, ielmts, randfunc, args, split);


%------------------------------------------------------------------
function varargout = rand_ind_private (obj_array, ind, ielmts, randfunc, args, split)
% Given a list of indices, find location and number of unique occurences
%
%   >> X = rand_ind_private (obj_array, ind)
%
% Efficient computation is achieved by a making a single call to the random
% sampling function for each unique object referred to in the index array ind.
% If the random sampler is vectorised, then this will massively outweigh
% the cost of sorting ind that is required to perform this operation.
%
% Input:
% ------
%   obj_array   Array of objects from which random samples must be pulled
%
%   ind         Array of indices of elements of obj_array for which random
%              samples are pulled.
%
%   ielmts      If not empty, an array the same size as input argument ind that
%              gives the index of elements within the object identified by
%              ind.
%               If empty, then treated as not present
%
%   randfunc    Handle to random sampling function. Must have one of the forms:
%
%               - If ielmts not present:
%       [X1, X2,...] = randfunc (object)               % generate a single random point
%       [X1, X2,...] = randfunc (object, n)            % n x n matrix of random points
%       [X1, X2,...] = randfunc (object, sz)           % array of size sz
%       [X1, X2,...] = randfunc (object, sz1, sz2,...) % array of size [sz1,sz2,...]
%       [X1, X2,...] = randfunc (..., p1, p2, ...)     % with further optional arguments
%                           % It is assumed that the method can resolve any ambiguities
%                           % between p1 and n, sz or szn
%
%               - If ielmts is present:
%       [X1, X2,...] = randfunc (object, ielmts)
%       [X1, X2,...] = randfunc (object, ielmts, p1, p2, ...)
%
%   args        Call array of arguments to randfunc: args = {p1, p2, ...}
%
%   split       Logical row vector with length of args, true where an
%               argument is to be split
%
% Output:
% -------
%   X1, X2,...  Arrays of random points. The output arrays for each value of
%               ind are stacked. For example, if the size of X1 for a single
%               call to randfunc is sz1, then the size of X1 returned by
%               rand_ind is [sz1,size(ind)] but with leading singleton
%               dimensions in size(ind) used to hold trailing dimensions of
%               sz1.
%
%               Note the output array size is not necessarily the same as
%               that obtained by using the matlab intrinsic function squeeze.
%
%               See also size_array_stack for details
%
%               EXAMPLES
%                   randfunc output      size(ind)        size(X1)
%                       [1,3]               [1,5]           [1,3,5]
%                       [3,1]               [1,5]           [3,5]
%                       [3,1]               [1,1,5]         [3,1,5]


% Sort the ind and create an index array that relates back to the
% original ordering
if issorted(ind(:)) % case that the array is already sorted
    if ind(1)~=ind(end)
        B = ind(:);
        ix = [];    % empty will indicate that no reordering is needed later
    else
        % *** NEEDS ATTENTION ***
        % *** CASE OF SINGLE UNIQUE OBJECT ***
        % *** SPLITTING P(i) ? ***
        X = obj_array(ind(1)).rand(size(ind), varargin{:});    % all ind(:) are the same
        return
    end
else
    [B, ix] = sort(ind(:));
end
nend = [find(diff(B)); numel(B)];
nbeg = 1 + [0;nend(1:end-1)];
nel = nend - nbeg + 1;
indu = B(nbeg);     % the unique element index numbers

if ~(isempty(ix) || ~isempty(ielmts))
    % If ind was sorted, then if it exists reorder ielmts ot match
    iel = reshape (ielmts(ix), [], 1);  % column vector
end

% Split arguments requested by iargs into stacks of arrays, the size of the
% stacks matching the size of ind
args_split = split_args (args(split), size(ind), ix, nel);
args_tmp = cell(size(args));
args_tmp(~split) = args(~split);   % arguments that are not split

% Determine size of output arguments from first call to randfunc
nout = nargout;
args_tmp(split) = args_split(:,1);
if isempty(ielmts)
    % Case of randfunc acting on each unique object as a whole, with a
    % size descriptor passed to randfunc: syntax
    %   [X1, X2,...] = randfunc (object, sz, p1, p2,...)
    [Xtmp{1:nout}] = randfunc (obj(indu(1)), [nel(1),1], args_tmp{:});
else
    % Case of randfunc acting on elements within each unique object, with
    % an index array that says which elements
    %   [X1, X2,...] = randfunc (object, ielmts, p1, p2, ...)
    [Xtmp{1:nout}] = randfunc (obj(indu(1)), iel(1), args_tmp{:});
end
sz = cellfun (@size, Xtmp, 'UniformOutput', false);             % sizes of outputs from first call
sz_root = cellfun (@(x)size_array_split(x, [nel(1),1]), sz);    % sizes of underlying output arrays

% Fill cell array with output from unique objects
X = cellfun (@(x)(NaN([prod(x),numel(ind)])), sz_root, 'UniformOutput', false);
for i = 1:numel(indu)
    if i>1
        args_tmp(split) = args_split{:,i};
        if isempty(ielmts)
            [Xtmp{1:nout}] = randfunc (obj(indu(i)), [nel(i),1], args_tmp{:});
        else
            [Xtmp{1:nout}] = randfunc (obj(indu(i)), iel(i), args_tmp{:});
        end
    end
    if ~isempty(ix)
        ixu = ix(nbeg(i):nend(i));
    else
        ixu = nbeg(i):nend(i);
    end
    for j=1:nout
        X{j}(:,ixu) = reshape (Xtmp{j}(:), [prod(sz_root{j}),nel(i)]);
    end
end

% Reshape output
varargout = cellfun(@(x,y)reshape(x,size_array_stack(y,size(ind))), X, sz0, 'UniformOutput', false);




% Determine the size of the random sample for a single element, then
% loop over the number of unique elements making vectorised call to the
% random sampling function. Finally, re-order the random samples back to
% the order of the input array ind
sz = size(obj_array(indu(1)).rand(1), varargin{:});    % size of random array returned by object rand method

X = NaN(prod(sz),nend(end));
for i=1:numel(indu)
    X(:,nbeg(i):nend(i)) = obj_array(indu(i)).rand(nel(i),1,varargin{:});
end
if ~isempty(ix)
    X(:,ix) = X;
end
X = squeeze(reshape(X,[sz,size(ind)]));
