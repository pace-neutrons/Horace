function [sz0, ok, mess] = size_array_split (sz_full, sz_stack)
% Return the size of the root array in a stack of those arrays
%
%   >> [sz0, ok, mess] = size_array_split (sz_full, sz_stack)
%
% Input:
% ------
%   sz_full     Size of the stacked array.
%
%   sz_stack    Size of the array by which to stack arrays of size sz0, as
%              obtained by using the matlab instrinsic function 'size'
%
% Output:
% -------
%   sz0         Size of the arrays that were stacked, as obtained by using
%              the matlab instrinsic function 'size'
%
% This is the inverse of the function size_array_stack
%
% See also size_array_stack


ok = true;
mess = '';

if numel(sz_full) >= numel(sz_stack)
    % Remove trailing singletons from sz_full and sz_stack
    ind = find(fliplr(sz_full)~=1,1);   % first non-singleton counting backwards
    if ~isempty(ind)
        sz_full = sz_full(1:end-ind+1);
    else
        sz_full = zeros(1,0);
    end
    ind = find(fliplr(sz_stack)~=1,1);   % first non-singleton counting backwards
    if ~isempty(ind)
        sz_stack = sz_stack(1:end-ind+1);
    else
        sz_stack = zeros(1,0);
    end
    
    % Get number of dimensions in sz_stack following leading singletons
    ind = find(sz_stack~=1,1);      % first non-singleton dimension
    if ~isempty(ind)
        n = numel(sz_stack) - ind + 1;
    else
        n = 0;    % occurs is sz_stack is empty
    end
    
    % Check that the non-singleton dimensions of the stack array match the
    % final dimensions of the full array
    if all(sz_full(end-n+1:end)==sz_stack(end-n+1:end))
        sz0 = sz_full(1:end-n);
        if numel(sz0)>=3 && sz0(end)==1     % must have unallowed trailing singleton dimensions
            mess = 'The full array cannot be resolved into a stack of arrays with the given stack size';
            sz0 = []; ok = false; if nargout<2, error(mess), end
        end
    else
        mess = 'The full array cannot be resolved into a stack of arrays with the given stack size';
        sz0 = []; ok = false; if nargout<2, error(mess), end
    end
    
else
    mess = 'The number of dimensions of the stacking array is larger than that of the full array';
    sz0 = []; ok = false; if nargout<2, error(mess), end
end
