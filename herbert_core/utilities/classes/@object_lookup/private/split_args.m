function [args_split, args_first] = split_args (args, sz_stack, ix, nelmts)
% Split arrays into chunks, after re-ordering if necessary
%
%   >> argsplit = split_args (args, sz_stack, ix, nelmt)
%
% Input:
% ------
%   args        Cell array of arguments.
%
%   sz_stack    Size of the stacking array. Each array in args is made by
%              stacking arrays according to an array with size sz_stack.
%
%   ix          Reordering vector. Before splitting, each argument is
%              reshaped into a 2D array with outer dimension equal to
%              prod(sz_stack) and the columns are re-ordered according as
%              ix. Must have numel(ix) = prod(sz_stack).
%               If ix is empty, then no reordering is performed.
%
%   nelmts      Vector of numbers of elements by which to split the
%              flattened outer dimension of the (potentially) re-ordered
%              arrays that consitute the elements of args. Must have
%              sum(nelmts) = prod(sz_stack)
%
% Output:
% -------
%   args_split  Cell array size(numel(arg),numel(nelmt)) containing the
%              split arguments, retaining the inner dimensions of the
%              stacked arrays.
%
%   args_first  Cell array size(numel(arg),1) containing the split
%              arguments for the first element in ix. Useful to provide
%              example arguments for test function calls.


nstack = prod(sz_stack);
args_split = cell(numel(args), numel(nelmts));
args_first = cell(numel(args), 1);
for i=1:numel(args)
    % Turn argument into 2D array, first dimension has length equal to
    % the number of elements in the inner arrays, the second has length
    % equal to the number of elements in the stacking array
    [sz_root, ok, mess] = size_array_split (size(args{i}), sz_stack);
    nroot = prod(sz_root);
    if ~ok
        error ('HERBERT:split_args:invalid_argument', mess);
    end
    tmp = reshape(args{i}, [nroot, nstack]);
    
    % Split argument into a cell array of 2D arrays, re-ordered first if
    % requested
    if ~isempty(ix)
        args_split_tmp = mat2cell(tmp(:,ix), nroot, nelmts);
    else
        args_split_tmp = mat2cell(tmp, nroot, nelmts);
    end
    
    % Reshape so that the original inner dimensions are recovered but the
    % the outer dimensions are flattened
    sz_full = arrayfun(@(x)size_array_stack(sz_root,[x,1]), nelmts,...
        'UniformOutput', false);
    args_split(i,:) = cellfun(@(x,y)reshape(x,y), args_split_tmp, sz_full(:)',...
        'UniformOutput', false);
    
    % Create arguments for the first element of ix
    if nargout>1
        args_first{i} = reshape(args_split_tmp{1}(:,1), sz_root);
    end
end
