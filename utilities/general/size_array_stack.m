function sz_full = size_array_stack (sz0, sz_stack)
% Return the size of the array of arrays made by stacking arrays
%
%   >> sz_full = size_array_stack (sz0, sz_stack)
%
% Input:
% ------
%   sz0         Size of the arrays to be stacked, as obtained by using the
%              matlab instrinsic function 'size'
%
%   sz_stack    Size of the array by which to stack arrays of size sz0, as
%              obtained by using the matlab instrinsic function 'size'
%
% Output:
% -------
%   sz_full     Size of the stacked array.
%               Leading singletons in sz_stack will be expanded to hold
%              trailing dimensions of sz0 once stripped of any trailing
%              singletons. For example sz0 = [2,5] and sz_stack = [1,20]
%              results in sz_full = [2,5,20]
%
% This function looks after the case of leading singleton dimensions in the
% way that using 'squeeze' on stacked arrays does not. For example, if
% sz0 = [3,5] and sz_stack = [1,1,1,4], squeeze would give the size of the
% full array as [3,5,4], whereas this function gives [3,5,1,4]. Likewise,
% with [3,1] with [1,1,2] squeeze yields [3,2] whereas this function
% gives [3,1,2].
%
% The inverse of this fuinction is size_array_split
%
% See also size_array_split


% Remove trailing singletons from sz0 (could be there if column or scalar)
ind = find(fliplr(sz0)~=1,1);   % first non-singleton counting backwards
if ~isempty(ind)
    sz0 = sz0(1:end-ind+1);
else
    sz0 = zeros(1,0);
end

% Get index of last leading singleton dimension in the stack array
ind = find(sz_stack~=1,1);      % first non-singleton
if ~isempty(ind)
    ind = ind - 1;
else
    ind = numel(sz_stack);
end

% Soak up non-singleton dimensions into leading singletons in the stack
ndim_common = min(numel(sz0),ind);
sz_full = [sz0,sz_stack(ndim_common+1:end)];

% Remove trailing singletons if larger than two-dimensional
ind = find(fliplr(sz_full(3:end))~=1,1);% first non-singleton counting backwards
if ~isempty(ind)
    sz_full = sz_full(1:numel(sz_full)-ind+1);
else
    sz_full = sz_full(1:2);
end
