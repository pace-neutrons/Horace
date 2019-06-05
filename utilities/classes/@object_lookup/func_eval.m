function varargout = func_eval (obj, varargin)
% Evaluate an object method for indexed occurences in an object lookup table
%
%   >> [X1, X2,...] = func_eval (obj, iarray, ind, funchandle, p1, p2,...)
%   >> [X1, X2,...] = func_eval (obj, ind, funchandle, p1, p2,...)
%
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
%   X1, X2,...  Output arguments. If the size of X1 for a single call to
%               funchandle is sz1, then the size of X1 is [sz1,size(ind)]
%               with singleton dimensions in the size squeezed away.


% Check validity
if ~isscalar(obj)
    error('Only operates on a single object_lookup (i.e. object must be scalar');
end
if ~obj.filled
    error('The object_lookup is not initialised')
end

% Parse the input
narg = numel(varargin);
if narg>=2 && isa(varargin{2},'function_handle')
    if numel(obj.indx_)==1
        iarray = 1;
        ind = varargin{1};
        funchandle = varargin{2};
        arg = varargin(3:end);
    else
        error('Must give index to the object array from which samples are to be drawn')
    end
elseif narg>=3 && isa(varargin{3},'function_handle')
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


[varargout{1:nargout}] = func_eval_private (obj.object_array_, obj.indx_{iarray}(ind), funchandle, arg);


%------------------------------------------------------------------
function varargout = func_eval_private (obj, ind, funchandle, arg)

% Find unique occurences of ind
% In principle, ind could be a large array (e.g. the 10^7 pixels in a large cut
% from Horace). We only want to evaluate the function for distinct objects in the
% lookup array, as the function could be expensive to evaluate.
N = max(ind);
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
    varargout = cellfun (@(x,y)(repmat(x,size_array_stack(ones(size(y)),size(ind)))),...
        Xtmp, sz, 'UniformOutput', false);
end
