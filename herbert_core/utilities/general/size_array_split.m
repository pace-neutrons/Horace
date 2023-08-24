function [sz_root, ok, mess] = size_array_split (sz_full, sz_stack)
% Return the size of the root array in a stack of those arrays
%
%   >> [sz_root, ok, mess] = size_array_split (sz_full, sz_stack)
%
% Input:
% ------
%   sz_full     Size of the stacked array.
%
%   sz_stack    Size of the array by which to stack arrays of size sz_root,
%              as obtained by using the matlab intrinsic function 'size'
%
% Output:
% -------
%   sz_root     Size of the arrays that were stacked, as obtained by using
%              the matlab intrinsic function 'size'
%
% This is the inverse of the function size_array_stack
%
% See also size_array_stack

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
if ~is_a_size (sz_full)
    error('full array size has invalid form')
end

if ~is_a_size (sz_stack)
    error('stack array size has invalid form')
end

% Algorithm proper
ok = true;
mess = '';

% Remove trailing singletons from sz_full and sz_stack
sz_full = true_size(sz_full);
sz_stack = true_size(sz_stack);

if numel(sz_full) >= numel(sz_stack)
    % Get number of dimensions in sz_stack following leading singletons
    ind = find(sz_stack~=1,1);      % first non-singleton dimension
    if ~isempty(ind)
        % The stack array has at least one non-singleton dimension
        n = numel(sz_stack) - ind + 1;  % number of dimensions after leading singletons
        
        % The dimensions trailing leading singletons of the stack array must
        % match the trailing dimensions of the full array
        if all(sz_full(end-n+1:end)==sz_stack(end-n+1:end))           
            % Strip away the stack dimensions
            sz_root = sz_full(1:end-n);
            if numel(sz_stack)==numel(sz_full)
                sz_root = true_size(sz_root);   % remove trailing singletons
            elseif ~isempty(sz_root) && sz_root(end)==1
                mess = 'The full array cannot be resolved into a stack of arrays with the given stack size';
                sz_root = []; ok = false; if nargout<2, error(mess), end
            end
        else
            mess = 'The full array cannot be resolved into a stack of arrays with the given stack size';
            sz_root = []; ok = false; if nargout<2, error(mess), end
        end
        
    else
        % sz_stack is empty i.e. was originally [1,1] i.e. a scalar
        sz_root = sz_full;
    end
    
    % Add trailing singletons to the root array to give Matlab size of at least two
    if numel(sz_root)<2
        sz_root = [sz_root,ones(1,2-numel(sz_root))];
    end
    
else
    mess = 'The number of dimensions of the stacking array is larger than that of the full array';
    sz_root = []; ok = false; if nargout<2, error(mess), end
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
