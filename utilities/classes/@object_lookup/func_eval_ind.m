function varargout = func_eval_ind (obj, varargin)
% Evaluate an object method for indexed occurences in an object lookup table
%
%   >> [X1, X2,...] = func_eval_ind (obj, iarray, ind, funchandle, p1, p2,...)
%   >> [X1, X2,...] = func_eval_ind (obj, ind, funchandle, p1, p2,...)
%
%   >> [X1, X2,...] = func_eval_ind (..., 'split', val, funchandle, ...)
%
% The purpose is to evaluate functions of the form:
%       [X1, X2, X3...] = my_function (object, p1, p2,...)
%
% for a set of objects defined by index arguments iarray and ind, where
% the output arguments are deterministic (a situation that excludes random
% points as return arguments, for example).
%
% The arguments p1, p2, ... are assumed to have outer dimensions that match
% the dimensions of ind. The section of each argument corresponding to the
% unique object identified by iarray and ind will be passed to a single call
% of the function my_function for that object. It is assumed that arguments
% of my_function where outer dimensions of input arguments result in outer
% dimensions of output arguments being the same, that those input arguments
% can be rehaped with the final outer dimension of an array corresponding 
% to numel(ind).
%
% If one or more arguments are common to all calls, then use the optional 
% keyword-argument pair "...'split', val)" to indicate which arguments
% should be split.
%
% The function uses the internal identification of identical objects in the
% object lookup to minimise the actual number of calls to my_function to
% just once for each unique element in the input argument index array, ind.
% This is why the method is inappropriate for generating random points that
% are different for succesive calls to my_function.
%
% See also func_eval
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
%   ind         Array containing the indicies objects in the original
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
% Optional arguments:
%  'split',val  Keyword followed by an array with the indicies of the 
%              arguments p1,p2,...pn that are each to be consdered as an
%              array of arrays, where the size of the outer array matches
%              that of the indices array ind.
%               Default: split all arguments
%
%
% Output:
% -------
%   X1, X2,...  Output arguments. If the size of X1 for a single call to
%              funchandle is sz1, then the size of X1 is [sz1,size(ind)]
%              with singleton dimensions in the size squeezed away.


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
        split = true(size(arg));
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
    split = true(size(arg));
    
elseif narg>=4 && isa(varargin{4},'function_handle')
    if numel(obj.indx_)==1
        iarray = 1;
        ind = varargin{1};
        funchandle = varargin{4};
        arg = varargin(5:end);
        [ok,mess,split] = parse_split(varargin{2},varargin{3},numel(arg));
        if ~ok, error(mess), end
    else
        error('Must give index to the object array from which samples are to be drawn')
    end
    
elseif narg>=5 && isa(varargin{5},'function_handle')
    iarray = varargin{1};
    if ~isscalar(iarray)
        error('Index to original object array, ''iarray'', must be a scalar')
    end
    ind = varargin{2};
    funchandle = varargin{5};
    arg = varargin(6:end);
    [ok,mess,split] = parse_split(varargin{2},varargin{3},numel(arg));
    if ~ok, error(mess), end
    
else

    error('Insufficient number of input arguments')
end

[varargout{1:nargout}] = func_eval_ind_private (obj.object_store_,...
    obj.indx_{iarray}(ind), funchandle, arg, split);


%------------------------------------------------------------------------------
function [ok, mess, split] = parse_split (opt, val, narg)
% Parse the 'split' option to give a logical row vector, true where
% arguments are to be unpacked, false where not.
ok = false;
mess = '';
split = false(1,0);
if ~isempty(opt) && is_string(opt)
    if strncmpi(opt,'split',numel(opt))
        if isnumeric(val) && all(val(:)>=1) && all(val(:)<=narg) &&...
                all(rem(val,1)==0) && numel(unique(val(:)))==numel(val)
            split = false(1,narg);
            split(val) = true;
        else
            mess = 'Parameter indicies must be unique positive integers less than or equal to the number of function arguments';
        end
    else
        mess = 'If present, the option can only be the character string ''split''';
    end
else
    mess = 'If present, the option can only be a character string';
end


%------------------------------------------------------------------------------
function varargout = func_eval_ind_private (obj, ind, funchandle, arg, split)
% Perform function evaluation

% Get the unique index numbers
if issorted(ind(:))
    if ind(1)~=ind(end)
        B = ind(:);
        ix = [];    % empty will indicate that no reordering is needed later
    else
        % Special case that all evaluations are for one object only - evaluate and return
        [varargout{1:nargout}] = funchandle(obj(ind(1)),arg{:});    % all ind(:) are the same
        return
    end
else
    [B,ix] = sort(ind(:));
end
nend = [find(diff(B));numel(B)];
nbeg = 1+[0;nend(1:end-1)];
nelmt = nend-nbeg+1;

indu = B(nbeg);     % unique index numbers

% Split arguments that have outer dimension(s) that are requested to follow ind
argsplit = split_arr(arg(split),size(ind),ix,nelmt);

% Evaluate the function for the distinct object instances
nout = nargout;
argtmp = cell(size(arg));
argtmp(~split) = arg(~split);   % arguments that are not split

argtmp(split) = argsplit(:,1);
[Xtmp{1:nout}] = funchandle (obj(indu(1)), argtmp{:});      % get outputs from first call
sz = cellfun(@size, Xtmp, 'UniformOutput', false);          % sizes of outputs from first call
sz0 = cellfun(@(x)size_array_split(sz,[nelmt(1),1]), sz);   % sizes of underlying output arrays

% Fill cell array with output from unique objects
X = cellfun (@(x)(NaN([prod(x),numel(ind)])), sz0, 'UniformOutput', false);
for i=1:numel(indu)
    if i>1
        argtmp(split) = argsplit{:,i};
        [Xtmp{1:nout}] = funchandle (obj(indu(i)), argtmp{:});
    end
    if ~isempty(ix)
        ixu = ix(nbeg(i):nend(i));
    else
        ixu = nbeg(i):nend(i);
    end
    for j=1:nout
        X{j}(:,ixu) = reshape(Xtmp{j}(:), [prod(sz{j}),nelmt(i)]);
    end
end
% Reshape output
varargout = cellfun(@(x,y)reshape(x,size_array_stack(y,size(ind))), X, sz0, 'UniformOutput', false);


%------------------------------------------------------------------------------
function argsplit = split_arr(arg,sz_stack,ix,nelmt)
% Split arrays into chunks, after re-ordering if necessary
%
%   >> argsplit = split_arr(arg,sz_stack,ix,nelmt)
%
% Input:
% ------
%   arg         Cell array of arguments
%
%   sz_stack    Size of the stacking array. Each array in arg is made by
%               stacking arrays according to an array with size sz_stack
%
%   ix          Reordering vector. Before splitting, each argument is
%               reshaped into a 2D array with outer dimension equal to
%               prod(sz_stack). Before splitting, the columns are
%               re-ordered according as ix
%
%   nelmt       Splitting vector. The re-ordered array is split along the
%               outer dimension into chunks given by nelmt. Must have
%               sum(nelmt) = prod(sz_stack)
%
% Output:
% -------
%   argsplit    Cell array size(numel(arg),numel(nelmt)) containing the
%               split arguments, retianing the inner dimensions of the
%               stacked arrays


nstack = prod(sz_stack);
argsplit = cell(numel(arg), numel(nelmt));
for i=1:numel(arg)
    % Turn argument into 2D array
    [sz0, ok, mess] = size_array_split (size(arg{i}), sz_stack);
    if ~ok
        ME = MException('split_arr:error', mess);
        throwAsCaller(ME)
    end
    tmp = reshape(arg{i},[prod(sz0),nstack]);
    % Split argument into a cell array of 2D arrays
    if ~isempty(ix)
        tmp_argsplit = mat2cell(tmp(:,ix), prod(sz0), nelmt);
    else
        tmp_argsplit = mat2cell(tmp, prod(sz0), nelmt);
    end
    % Reshape so only the outer dimension remains unchanged
    sz_full = arrayfun(@(x)size_array_stack(sz0,[x,1]), nelmt,...
        'UniformOutput', false);
    argsplit(i,:) = cellfun(@(x,y)reshape(x,y), tmp_argsplit, sz_full(:)',...
        'UniformOutput', false);
end
