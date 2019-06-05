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
