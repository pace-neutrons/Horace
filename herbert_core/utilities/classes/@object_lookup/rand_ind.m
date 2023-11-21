function varargout = rand_ind (obj, iarray, varargin)
% Generate random samples for indexed occurences within a particular object array
%
% It is assumed that there is a method of the class of the objects in the array
% that provides random samples - which can be of any class (numeric, logical,
% user-defined classes...) and any number of return arguments. This could be,
% for example a random vector describing a point in space together with a random
% colour returned as a character string.
%
% The purpose of this method is to efficiently handle the book-keeping of
% generating and returning the samples for a large number of indexed occurences
% into a compressed representation of the object array as an object_lookup
% object.
% 
% There are two forms:
%   - The indexed occurences are to objects in an object array:
%       >> [X1, X2,...] = rand_ind (obj, iarray, ind, randfunc, ...)
%     (the object array is defined by arguments obj and iarray)
%
%   - The indexed occurences are to objects that themselves have internal indexing:
%       >> [X1, X2,...] = rand_ind (obj, iarray, ind, ielmts, randfunc, ...)
%
% Details are given below.
%
% Case 1: Indexed occurences are to objects in an object array
% ------------------------------------------------------------
%   >> [X1, X2,...] = rand_ind (obj, iarray, ind, randfunc)
%   >> [X1, X2,...] = rand_ind (..., randfunc, p1, p2, ...)
%   >> [X1, X2,...] = rand_ind (..., 'split', randfunc, p1, p2, ...)
%   >> [X1, X2,...] = rand_ind (..., 'split', iargs, randfunc, p1, p2, ...)
%
% The purpose is to return random samples from an array of objects, defined by
% index iarray into the compressed array-of-arrays held in argument obj, and
% then select one random sample per element in that array as indexed by
% the array ind.
%
% It requires a function handle to a random sampling method of the form:
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
%   method can internally resolve any ambiguities between p1 and sz. The
%   optional parameters p1, p2,... apply to all elements, 
%
%   The other conventional forms for the syntax of the Matlab intrinsic
%   random number generator rand are acceptable so long as the method can
%   distinguish them from the above syntax i.e.
%   [X1, X2,...] = randfunc (object, n)            % n x n matrix of random samples
%   [X1, X2,...] = randfunc (object, sz1, sz2,...) % array of size [sz1,sz2,...]
%   [X1, X2,...] = randfunc (..., p1, p2, ...)     % with further optional arguments
%
%
% Case 2: Indexed occurences are to objects that are themselves arrays
% --------------------------------------------------------------------
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
%       [X1, X2,...] = randfunc (object, n)            % n x n matrix of random samples
%       [X1, X2,...] = randfunc (object, sz)           % array of size sz
%       [X1, X2,...] = randfunc (object, sz1, sz2,...) % array of size [sz1,sz2,...]
%       [X1, X2,...] = randfunc (..., p1, p2, ...)     % with further optional arguments
%                           % It is assumed that the method can resolve any ambiguities
%                           % between p1 and n, sz or sz1, sz2,...
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
%   X1, X2,...  Arrays of random samples. The output arrays for each value of
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
[ind, ielmts, randfunc, args, split] = parse_eval_method (varargin{:});

% Create an array of indicies to the unique objects stored in obj,
% corresponding to the input index array ind
ind_unique_obj = reshape (obj.indx_{iarray}(ind), size(ind));   % retain shape of ind

% Call a private function that efficiently randomly samples the objects
israndfunc = true;
[varargout{1:nargout}] = call_eval_method (obj.object_store_, ...
    ind_unique_obj, ielmts, israndfunc, randfunc, args, split);
