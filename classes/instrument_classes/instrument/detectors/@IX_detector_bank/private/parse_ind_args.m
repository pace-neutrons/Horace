function [sz, ix, iarr, ind, args] = parse_ind_args (nel, argnam, varargin)
% Check that the array indices and optional arrays are consistently sized
%
%   >> [sz, ix, iarr, ind, args] = parse_ind_args (nel, argnam, arg1, arg2,...)
%
%   >> [sz, ix, iarr, ind, args] = parse_ind_args (nel, argnam, ind_in, arg1, arg2,...)
%
% This is a utility routine to parse input arguments
%
%
% Input:
% ------
%   nel         The number of elements in each array
%
%   argnam      Character string or cell array of strings of the names of
%               numerical arguments that are expected other than 'ind' below
%
%   ind_in      Indices of elements. Scalar or array.
%               Default: all detectors (i.e. ind = 1:sum(nel(:)))
%
%   arg1,arg2.. Numerical parameters whose names were given in 'argnam'.
%               Each argument must be a scalar or an array, with all arrays
%               having the same number of elements, including 'ind'.
%
%
% Output:
% -------
%   sz          Size of reference output array - used to reshape output.
%               If one of ind or wvec is scalar, then it will
%              be the size of that array; if both are arrays, then
%              it will be the size of wvec
%
%   ix          Column vector of indices that give the positions into ind_in
%              of the reordered values in iarr and ind (below)
%
%   iarr        Column vector of array indices from which to there is at
%              least one element selected by the global indices list.
%               iarr is sorted into increasing order
%
%   ind         If elements come from a single array (i.e. iarr is scalar)
%              then ind is a column vector of local indicies in that array.
%               If elements came from two or more arrays, (i.e. a vector)
%              then ind is a column cell array of column vectors of local
%              indices into the arrays in the order originally given by iarr.
%
%   args        Cell array (row) of arguments obtained by repackaging
%              arg1, arg2. If iarr is non-scalar i.e. elements given by 
%              ind come from more than one array, then any of arg1, arg2,...
%              that are arrays are repackaged just as 'ind'


if is_string(argnam)
    argnam = {argnam};
elseif ~iscellstr(argnam)
    throwAsCaller(MException('parse_ind_args:invalid_arguments',...
        'Argument names must a character string or cell array of character strings'))
end
narg = numel(argnam);

% Parse the input index array, if there is one
if numel(varargin)==narg || numel(varargin)==narg+1
    try
        if numel(varargin)==narg
            ind_given = false;
            [sz, ix, iarr, ind] = parse_ind (nel);
            args_in = varargin;
        else
            ind_given = true;
            [sz, ix, iarr, ind] = parse_ind (nel, varargin{1});
            args_in = varargin(2:end);
        end
        if numel(args_in)==0
            args = cell(1,0);       % empty return
            return
        end
    catch ME
        ME.throwAsCaller
    end
else
    throwAsCaller(MException('parse_ind_args:invalid_arguments',...
        'Check the number of input arguments'))
end

% Parse the other arguments
n = [prod(sz),cellfun(@numel,args_in)];
ok = (n==max(n)|n==1);
if ~all(ok)
    if ind_given
        throwAsCaller(MException('parse_ind_args:invalid_arguments',...
            ['''ind'' and other arguments must each be scalar or array with',...
            ' same number of elements as all other arrays']))
    else
        throwAsCaller(MException('parse_ind_args:invalid_arguments',...
            ['Argument(s) must be scalar or arrays with number of elements',...
            ' equal to the number of indicies']))
    end
end

if isscalar(iarr)
    % All elements from one array; we just need to turn arrays into columns
    args = args_in;
    for i=1:numel(args)
        args{i} = args{i}(:);
    end
else
    % Elements from multiple arrays; must split and reorder
    narr = cellfun(@numel, ind);    % number of elements from each array
    args = cell(size(args_in));
    for i=1:numel(args_in)
        if ~isscalar(args_in{i})
            tmp = args_in{i}(ix);
            args{i} = mat2cell(tmp(:),narr,1);
        else
            args{i} = args_in{i}(:);
        end
    end
end

% Update sz if needed to size of first non-scalar argument following ind
args_nonscalar = (n(2:end)~=1);
if any(args_nonscalar)
    sz = size(args_in{find(args_nonscalar,1)});
end
