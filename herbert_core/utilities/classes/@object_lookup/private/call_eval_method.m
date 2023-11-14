function varargout = call_eval_method (obj, ind, ielmts, israndfunc, func, args, split)
% Call evaluation method on an indexed subset of and object array
%
%   >> [X1, X2,...] = call_eval_method (obj, ind, ielmts, israndfunc, func, args, split)
%
% Efficient computation is achieved by a making a single call to the 
% function for each unique object referred to in the index array ind.
% If the function to be evaluated is vectorised, then this will massively
% outweigh the cost of sorting the index array ind and other overheads that is
% required to perform this operation.
%
% Input:
% ------
%   obj         Array of objects from which random samples must be pulled or the
%              function is to be evaluated
%
%   ind         Array of indices of elements of obj for which random
%              samples are pulled.
%
%   ielmts      If not empty, an array the same size as input argument ind that
%              gives the index of elements within the object identified by
%              ind.
%               If empty, then treated as not present
%
%   israndfunc  False: if the function is deterministic (i.e. successive calls
%              with the same input arguments will always produce the same
%              output)
%               True: if the function be evaluated is required to return random
%              samples (i.e. succesive calls with the same input arguments will
%              return different results because there is a random sampling
%              aspect to the evaluation)
%
%   func        Handle to function. Must have one of the forms:
%
%               For the case of a deterministic function evaluation:
%               ----------------------------------------------------
%               - If ielmts not present:
%       [X1, X2,...] = func (object, p1, p2, ...)
%
%               - If ielmts is present:
%       [X1, X2,...] = func (object, ielmts)
%       [X1, X2,...] = func (object, ielmts, p1, p2, ...)
%
%               For the case of a random simpling function:
%               -------------------------------------------
%               - If ielmts not present:
%       [X1, X2,...] = randfunc (object)               % generate a single random point
%       [X1, X2,...] = randfunc (object, n)            % n x n matrix of random samples
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
%   split       Logical row vector with length of args, element is true where
%               the corresponding argument is to be split, false if not
%
%               For the case of a random simpling function:
%               -------------------------------------------
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


nout = nargout;
present_ielmts = ~isempty(ielmts);

% Determine for which elements of ind the function is going to be evaluated, and
% for which internal indices if there is any internal indexing. The value of ind
[ind_eval, iel, ix, neval, nbeg, nend] = split_ind_ielmts (ind, ielmts, ...
    israndfunc, any(split));


% If requested, split the each of the indicated arguments in args into a number
% of stacks of arrays, one stack for each value of ind_eval. For a given
% argument and value ind_eval(i), the corresponding stack is made from stacking
% the arrays for the required neval(i) evaluations of the function
args_split = split_args (args(split), size(ind), ix, neval);
args_tmp = cell(size(args));
args_tmp(~split) = args(~split);   % arguments that are not split


% Make the call for the first value of ind_eval
args_tmp(split) = args_split(:,1);
if ~present_ielmts
    if israndfunc
        % Case of random function acting on an object as a whole, with
        % a size descriptor requesting an array of random samples. Syntax:
        %   [X1, X2,...] = func (object, sz, p1, p2,...)
        [Xtmp{1:nout}] = func (obj(ind_eval(1)), [neval(1),1], args_tmp{:});
    else
        % Case of a deterministic function. Only needs to be called once for a
        % given set of input arguments. Multiple occurences of a unique object
        % and argument set (i.e. neval(1)>1) will be handled by applying repmat
        % to the output later on when filling the final output arrays
        [Xtmp{1:nout}] = func (obj(ind_eval(1)), args_tmp{:});
    end
else
    % Case of function acting on elements within each the object with index 
    % ind_eval(1), with an index array that says which elements. Syntax:
    %   [X1, X2,...] = func (object, ielmts, p1, p2, ...)
    [Xtmp{1:nout}] = func (obj(ind_eval(1)), iel(nbeg(1):nend(1)), args_tmp{:});
end


% Determine sizes of the underlying output arguments from a call to the function
% by using the number calls if a random function or number of internal elements.
sz = cellfun (@size, Xtmp, 'UniformOutput', false); % sizes of outputs from first call
if israndfunc || present_ielmts
    sz_root = cellfun (@(x)size_array_split(x, [neval(1),1]), sz, 'UniformOutput', false);
else
    sz_root = sz;
end


% Fill cell array with output from unique objects. Each element of the cell
% array is a 2D array, the first dimension equal to the number of elements in
% the underlying corresponding output array from randfunc, and the second
% dimension equal to the number of elements in ind
X = cellfun (@(x)(NaN([prod(x),numel(ind)])), sz_root, 'UniformOutput', false);
for i = 1:numel(ind_eval)
    % Skip the evaluation of randfunc for indu(1), as it has already been
    % done
    if i>1
        args_tmp(split) = args_split(:,i);
        if ~present_ielmts
            if israndfunc
                [Xtmp{1:nout}] = func (obj(ind_eval(i)), [neval(i),1], args_tmp{:});
            else
                [Xtmp{1:nout}] = func (obj(ind_eval(i)), args_tmp{:});
            end
        else
            [Xtmp{1:nout}] = func (obj(ind_eval(i)), iel(nbeg(i):nend(i)), args_tmp{:});
        end
    end
    % Fill appropriate columns of the elements of X, accounting for reordering
    % of ind and the case of a deterministic function acting on objects with no
    % internal indexing, which needs to be replicated for the number of times
    % that the unique index indu appeared in ind.
    if ~isempty(ix)
        ixu = ix(nbeg(i):nend(i));
    else
        ixu = nbeg(i):nend(i);
    end
    if israndfunc || present_ielmts
        for j=1:nout
            X{j}(:,ixu) = reshape (Xtmp{j}(:), [prod(sz_root{j}),neval(i)]);
        end
    else
        for j=1:nout
            X{j}(:,ixu) = repmat (Xtmp{j}(:), [1,neval(i)]);
        end
    end
end

% Reshape output arguments to correspond to the stacking of the underlying root
% argument sizes for a single call to the function
varargout = cellfun(@(x,y)reshape(x,size_array_stack(y,size(ind))), X, sz_root, ...
    'UniformOutput', false);
