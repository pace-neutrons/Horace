function varargout = rand_ind (obj, iarray, varargin)
% Generate random samples for indexed occurences in an object_lookup
%
%   >> [X1, X2,...] = rand_ind (obj, iarray, ind, randfunc)
%   >> [X1, X2,...] = rand_ind (..., randfunc, p1, p2, ...)
%   >> [X1, X2,...] = rand_ind (..., 'split', randfunc, p1, p2, ...)
%   >> [X1, X2,...] = rand_ind (..., 'split', iargs, randfunc, p1, p2, ...)
%
% The purpose is to return random points from an array of objects, defined by
% index iarray into the compressed array-of-arrays held in argument obj, and
% then select one random sample per element in that array as indexed by
% the array ind.
%
% It requires a random sampling method of the form:
%
%   [X1, X2,...] = randfunc (object)               % generate a single random sample
%   [X1, X2,...] = randfunc (object, sz)           % array of random samples size sz
%   [X1, X2,...] = randfunc (..., p1, p2, ...)     % with further optional arguments
%   
%   where the argument object is one element of the array of objects (as
%   selected by obj and iarray), and X1, X2,... are random samples, for
%   example random scalars, vectors or any other object, or any mixture of 
%   object types.
%
%   If there are optional arguments p1, p2,..., it is required that the
%   method can internally resolve any ambiguities between p1 and sz.
%
%   The other conventional forms for the syntax of the Matlab intrinsic
%   random number generator rand are acceptable so long as the method can
%   distinguish them from the above syntax i.e.
%   [X1, X2,...] = randfunc (object, n)            % n x n matrix of random samples
%   [X1, X2,...] = randfunc (object, sz1, sz2,...) % array of size [sz1,sz2,...]
%   [X1, X2,...] = randfunc (..., p1, p2, ...)     % with further optional arguments
%
%
% If elements of the object array defined by obj and iarray have themselves 
% internal indexing, then random samples from individual elements within
% the elements of the array can be output by two index arrays ind and
% ielmts (both of the same shape and size) that together act as a double
% index. The syntax is otherwise the same:
%
%   >> [X1, X2,...] = rand_ind (obj, iarray, ind, ielmts, randfunc)
%   >> [X1, X2,...] = rand_ind (..., randfunc, p1, p2, ...)
%   >> [X1, X2,...] = rand_ind (..., 'split', randfunc, p1, p2, ...)
%   >> [X1, X2,...] = rand_ind (..., 'split', iargs, randfunc, p1, p2, ...)
%
% Here the random sampling method has a different form:
%
%   [X1, X2,...] = randfunc (object, ielmts)
%   [X1, X2,...] = randfunc (object, ielmts, p1, p2, ...)   % with optional arguments
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
[ind, ielmts, randfunc, args, split] = parse_rand_ind (varargin{:});

% Create an array of indicies to the unique objects stored in obj,
% corresponding to the input index array ind
ind_unique_obj = reshape (obj.indx_{iarray}(ind), size(ind));   % retain shape of ind

% Call a private function that efficiently randomly samples the objects
[varargout{1:nargout}] = rand_ind_private (obj.object_store_, ...
    ind_unique_obj, ielmts, randfunc, args, split);


%------------------------------------------------------------------
function varargout = rand_ind_private (obj, ind, ielmts, randfunc, args, split)
% Given a list of indices, find location and number of unique occurences
%
%   >> X = rand_ind_private (obj, ind)
%
% Efficient computation is achieved by a making a single call to the random
% sampling function for each unique object referred to in the index array ind.
% If the random sampler is vectorised, then this will massively outweigh
% the cost of sorting ind that is required to perform this operation.
%
% Input:
% ------
%   obj         Array of objects from which random samples must be pulled
%
%   ind         Array of indices of elements of obj for which random
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


present_ielmts = ~isempty(ielmts);

% Sort the ind and create an index array that relates back to the
% original ordering. Additionally, if ielmts exists, turn it into a column
% and reorder to match sorting of ind if it was sorted.
if issorted(ind(:)) % case that the array is already sorted
    B = ind(:);
    ix = [];    % empty will indicate that no reordering is needed later
    if present_ielmts
        iel = ielmts(:);
    end
else
    [B, ix] = sort(ind(:));
    if present_ielmts
        iel = reshape (ielmts(ix), [], 1);  % column vector
    end
end
nend = [find(diff(B)); numel(B)];
nbeg = 1 + [0;nend(1:end-1)];
nel = nend - nbeg + 1;
indu = B(nbeg);     % the unique element index numbers

% Split arguments requested by iargs into stacks of arrays, the size of the
% stacks matching the size of ind
args_split = split_args (args(split), size(ind), ix, nel);
args_tmp = cell(size(args));
args_tmp(~split) = args(~split);   % arguments that are not split


% Determine sizes of the underlying output arguments from a call to randfunc
% by making the call for the first unique object in the (sorted) index ind
nout = nargout;
args_tmp(split) = args_split(:,1);
if ~present_ielmts
    % Case of randfunc acting on each unique object as a whole, with a
    % size descriptor passed to randfunc. Syntax:
    %   [X1, X2,...] = randfunc (object, sz, p1, p2,...)
    [Xtmp{1:nout}] = randfunc (obj(indu(1)), [nel(1),1], args_tmp{:});
else
    % Case of randfunc acting on elements within each unique object, with
    % an index array that says which elements. Syntax:
    %   [X1, X2,...] = randfunc (object, ielmts, p1, p2, ...)
    [Xtmp{1:nout}] = randfunc (obj(indu(1)), iel(nbeg(1):nend(1)), args_tmp{:});
end
sz = cellfun (@size, Xtmp, 'UniformOutput', false); % sizes of outputs from first call
sz_root = cellfun (@(x)size_array_split(x, [nel(1),1]), sz, 'UniformOutput', false);


% Fill cell array with output from unique objects. Each element of the cell
% array is a 2D array, the first dimension equal to the number of elements in
% the underlying corresponding output array from randfunc, and the second
% dimension equal to the number of elements in ind
X = cellfun (@(x)(NaN([prod(x),numel(ind)])), sz_root, 'UniformOutput', false);
for i = 1:numel(indu)
    % Skip the evaluation of randfunc for indu(1), as it has already been
    % done
    if i>1
        args_tmp(split) = args_split(:,i);
        if ~present_ielmts
            [Xtmp{1:nout}] = randfunc (obj(indu(i)), [nel(i),1], args_tmp{:});
        else
            [Xtmp{1:nout}] = randfunc (obj(indu(i)), iel(nbeg(i):nend(i)), args_tmp{:});
        end
    end
    % Fill appropriate columns of the elements of X, accounting for reordering of ind
    if ~isempty(ix)
        ixu = ix(nbeg(i):nend(i));
    else
        ixu = nbeg(i):nend(i);
    end
    for j=1:nout
        X{j}(:,ixu) = reshape (Xtmp{j}(:), [prod(sz_root{j}),nel(i)]);
    end
end

% Reshape output arguments
varargout = cellfun(@(x,y)reshape(x,size_array_stack(y,size(ind))), X, sz_root, 'UniformOutput', false);
