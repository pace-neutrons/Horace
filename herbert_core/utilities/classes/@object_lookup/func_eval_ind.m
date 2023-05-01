function varargout = func_eval_ind (obj, varargin)
% Evaluate a function or method for indexed occurences in an object lookup table
%
%   >> [X1, X2,...] = func_eval_ind (obj, iarray, ind, funchandle, p1, p2,...)
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
%               If there was only one object array, then iarray is not
%              necessary (as it assumed iarray=1)
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
narg = numel(varargin);
if narg>=3 && isa(varargin{3},'function_handle')
    iarray = varargin{1};
    if ~isscalar(iarray)
        error('Index to original object array, ''iarray'', must be a scalar')
    end
    ind = varargin{2};
    funchandle = varargin{3};
    arg = varargin(4:end);
else
    error('Insufficient number of input arguments')
end

% Create an array of indicies to the unique objects stored in obj,
% corresponding to the input index array ind
ind_unique_obj = reshape (obj.indx_{iarray}(ind), size(ind));   % retain shape of ind

% Call a private function that evaluates only once per unique object instance
[varargout{1:nargout}] = func_eval_ind_private (obj.object_store_, ind_unique_obj, funchandle, arg);


%------------------------------------------------------------------
function varargout = func_eval_ind_private (obj, ind, funchandle, arg)

% Find unique occurences of ind
% In principle, ind could be a large array (e.g. the 10^7 pixels in a large cut
% from Horace). We only want to evaluate the function for distinct objects in the
% lookup array, as the function could be expensive to evaluate.
N = max(ind(:));
ind_present = logical(accumarray(ind(:),1,[N,1]));
ix = 1:N;
indu = ix(ind_present);     % unique occurences of ind

% Evaluate the function for the distinct instances
nout = nargout;
[Xtmp{1:nout}] = funchandle (obj(indu(1)), arg{:}); % get outputs from first call
sz = cellfun(@size, Xtmp, 'UniformOutput', false);  % sizes of outputs from first call

if numel(indu)>1
    % Fill cell array with output from unique objects
    X = cellfun (@(x)(NaN([prod(x),numel(ind)])), sz, 'UniformOutput', false);
    for i=1:numel(indu)
        if i>1
            [Xtmp{1:nout}] = funchandle (obj(indu(i)), arg{:});
        end
        for j=1:nout
            X{j}(:,i) = Xtmp{j}(:);
        end
    end
    
    % Expand according to the repetitions in indx
    ix = zeros(1,N);
    ix(indu) = 1:numel(indu);
    indu_expand = ix(ind);
    X = cellfun (@(x,y)(x(:,indu_expand)), X, 'UniformOutput', false);
    
    % Reshape output
    varargout = cellfun (@(x,y)(reshape(x, size_array_stack(y, size(ind)))),...
        X, sz, 'UniformOutput', false);
    
else
    % Only one unique object; simply repmat the output arguments and reshape
    varargout = cellfun (@(x,y)(reshape(repmat(x(:),[1,numel(ind)]),...
        size_array_stack(y, size(ind)))), Xtmp, sz, 'UniformOutput', false);
end
