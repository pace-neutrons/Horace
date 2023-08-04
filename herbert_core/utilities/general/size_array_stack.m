function sz_full = size_array_stack (sz_root, sz_stack)
% Return the size of the array of arrays made by stacking arrays
%
%   >> sz_full = size_array_stack (sz_root, sz_stack)
%
% Input:
% ------
%   sz_root     Size of the arrays to be stacked, as obtained by using the
%              matlab intrinsic function 'size'
%
%   sz_stack    Size of the array by which to stack arrays of size sz_root,
%              as obtained by using the matlab intrinsic function 'size'
%
% Output:
% -------
%   sz_full     Size of the stacked array.
%               Leading singletons in sz_stack will be used to hold
%              trailing dimensions of sz_root once stripped of any trailing
%              singletons. For example sz_root = [2,5] and sz_stack = [1,20]
%              results in sz_full = [2,5,20]
%
% This function looks after the case of leading singleton dimensions in the
% way that using 'squeeze' on stacked arrays does not. For example, if
% sz_root = [3,5] and sz_stack = [1,1,1,4], squeeze would give the size of
% the full array as [3,5,4], whereas this function gives [3,5,1,4].
% Likewise, with [3,1] with [1,1,2] squeeze yields [3,2] whereas this
% function gives [3,1,2].
%
% The inverse of this function is size_array_split
%
% See also size_array_split

% The premise to the algorithm is that trailing singleton dimensions are
% irrelevant to the dimensionality of an array
%   e.g. [2,1] has dimensions 1,
%        [1,1] has dimensions 0 (a scalar),
%        [1,0] has dimensions 2 because dimension extent 0 is significant.
%
% Therefore both the root and stacked arrays are reduced to dimensionality:
%   sz_root   []  or  [1,1,1...1,M1,M2,...Mm]
%   sz_stack  []  or  [1,1,1...1,N1,N2,...Nn]
% where M1,N1~=1 & Mm,Nn~=1 & m,n>=1.
% Note that any of M2,..M(m-1),N2...N(n-1) can be equal to 1.
%
% The full array then has dimensionality obtained by pushing as many Mi
% into the leading singletons of the stack dimensions:
%   e.g.  root      [1, 1, 1, 1,M1,M2,M3]
%         stack           [1, 1, 1, 1, 1,N1,N2,N3,N4]
%                  -----------------------------------
%         full      [1, 1, 1, 1,M1,M2,M3,N1,N2,N3,N4]
%
%
%   e.g.  root        [1, 1,M1,M2]
%         stack       [1, 1, 1, 1, 1, 1,N1,N2,N3,N4]
%                    --------------------------------
%         full        [1, 1,M1,M2, 1, 1,N1,N2,N3,N4]
%
% A block of singletons between the Ms and the Ns is only possible if the
% stack array and the full array have the same number of dimensions.
%
% At the very end, the matlab size is obtained by adding trailing
% singletons if necessary until the number of dimensions becomes two, as
% the Matlab size function would return.


% Elementary check that inputs are valid
if ~is_a_size (sz_root)
    error('root array size has invalid form')
end

if ~is_a_size (sz_stack)
    error('root array size has invalid form')
end

% Remove trailing singletons from sz_root and sz_stack
sz_root = true_size(sz_root);
sz_stack = true_size(sz_stack);

% Get index of last leading singleton dimension in the stack array
ind = find(sz_stack~=1,1);      % first non-singleton
if ~isempty(ind)
    ind = ind - 1;
else
    ind = numel(sz_stack);
end

% Soak up non-singleton dimensions into leading singletons in the stack
ndim_common = min(numel(sz_root),ind);
sz_full = [sz_root,sz_stack(ndim_common+1:end)];

% Add trailing singletons to the root array to give Matlab size of at least two
if numel(sz_full)<2
    sz_full = [sz_full,ones(1,2-numel(sz_full))];
end

% -------------------------------------------------------------------------
function ok = is_a_size (sz)
ok = isrow(sz) && numel(sz)>=2 && all(sz>=0) && all(rem(sz,1)==0);

% -------------------------------------------------------------------------
function sz_true = true_size (sz)
% Return true size once irrelevant trailing singletons have been stripped
ind = find(fliplr(sz)~=1,1);   % first non-singleton counting backwards
if ~isempty(ind)
    sz_true = sz(1:end-ind+1);
else
    sz_true = zeros(1,0);
end
