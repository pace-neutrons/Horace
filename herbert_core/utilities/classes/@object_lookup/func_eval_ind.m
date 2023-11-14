function varargout = func_eval_ind (obj, iarray, varargin)
% Evaluate a function or method for indexed occurences in an object lookup table
%
% The purpose is to evaluate functions of the form:
%       [X1, X2, X3...] = my_function (object, p1, p2,...)
%
% for a set of objects defined by index arguments iarray and ind, where
% the output arguments are deterministic (a situation that excludes random
% points as return arguments, for example).
%
% The function uses the internal identification of identical objects in the
% object lookup to minimise the actual number of calls to my_function to
% just once for each unique element in the input argument index array, ind.
% This is why the method is inappropriate for generating random points that
% are different for succesive calls to my_function.
% 
% There are two forms:
%   - The indexed occurences are to objects in an object array:
%       >> [X1, X2,...] = func_eval_ind (obj, iarray, ind, funchandle, p1, p2,...)
%     (the object array is defined by arguments obj and iarray)
%
%   - The indexed occurences are to objects that themselves have internal indexing:
%       >> [X1, X2,...] = func_eval_ind (obj, iarray, ind, elmts, funchandle, p1, p2,...)
%
%
% Case 1: Indexed occurences are to objects in an object array
% ------------------------------------------------------------
%   >> [X1, X2,...] = func_eval_ind (obj, iarray, ind, funchandle)
%   >> [X1, X2,...] = func_eval_ind (..., funchandle, p1, p2, ...)
%   >> [X1, X2,...] = func_eval_ind (..., 'split', funchandle, p1, p2, ...)
%   >> [X1, X2,...] = func_eval_ind (..., 'split', iargs, funchandle, p1, p2, ...)
%
% Very similar to arrayfun. The purpose is to evaluate functions of the form:
%       [X1, X2, X3...] = my_function (object, p1, p2,...)
%
% for a set of objects defined by index arguments iarray and ind, where
% the output arguments are deterministic (a situation that excludes random
% points as return arguments, for example).
%
% The function uses the internal identification of identical objects in the
% object lookup to minimise the actual number of calls to my_function to
% just once for each unique element in the input argument index array, ind.
% This is why the method is inappropriate for generating random points that
% are different for succesive calls to my_function.
%
%
% Input:
% ------
%   obj        object_lookup object
%
%   iarray      Scalar index of the original object array from the
%              cell array of object arrays from which the object lookup
%              was created.
%
%   ind         Array containing the indices objects in the original
%              object array referred to by iarray, for which the function is
%              to be evaluated. min(ind(:))>=1, max(ind(:))<=number of objects
%              in the object array selected by iarray
%
%   funchandle  Handle to function to be evaluated. The function
%              must have the form
%
%               [X1, X2, X3...] = my_function (object, p1, p2,...)
%
%              where X1, X2,... are the output arguments, which can be 
%              scalars or arrays of any objects that can be concantenated
%              and reshaped.
%
%   p1, p2,..   Any arguments to be passed to the function
%
%
% Output:
% -------
%   X1, X2,...  Output arguments. The output arrays for each value of ind
%               are stacked. For example, if the size of X1 for a single
%               call to funchandle is sz1, then the size of X1 returned by
%               func_eval_ind is [sz1,size(ind)] but with leading singleton
%               dimensions in size(ind) used to hold trailing dimensions of
%               sz1.
%
%               Note the output array size is not necessarily the same as
%               that obtained by using the matlab intrinsic function squeeze.
%
%               See also size_array_stack for details
%
%               EXAMPLES
%                   funchandle output    size(ind)        size(X1)
%                       [1,3]               [1,5]           [1,3,5]
%                       [3,1]               [1,5]           [3,5]
%                       [3,1]               [1,1,5]         [3,1,5]


% Check validity
if ~isscalar(obj)
    error('Only operates on a single object_lookup (i.e. object must be scalar');
end
if ~obj.filled
    error('The object_lookup is not initialised')
end

% Parse the input arguments
[ind, ielmts, funchandle, args, split] = parse_eval_method (varargin{:});

% Create an array of indicies to the unique objects stored in obj,
% corresponding to the input index array ind
ind_unique_obj = reshape (obj.indx_{iarray}(ind), size(ind));   % retain shape of ind

% Call a private function that efficiently evaluates the function over the
% objects
israndfunc = false;
[varargout{1:nargout}] = call_eval_method (obj.object_store_, ...
    ind_unique_obj, ielmts, israndfunc, funchandle, args, split);
