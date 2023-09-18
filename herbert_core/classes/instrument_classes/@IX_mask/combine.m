function obj_out = combine(varargin)
% Combine mask objects to form a single mask object
%
%   >> obj_out = combine (obj1, obj2,...)
%
% Input:
% ------
%   obj1, obj2,...  IX_mask objects or arrays of IX_mask objects
%
% Output:
% -------
%   obj_out         IX_mask object created by concatenating all the input
%                   objects, and then making a single IX_mask object by
%                   combining all IX_mask objects in the array, removing
%                   any duplicate indices.


% Catch trivial case of single, scalar or empty, IX_mask
if numel(varargin)==1 && numel(varargin{1})<=1
    obj_out = varargin{1};
    return
end

% Create a single array of IX_mask objects from the two or more IX_mask
% objects to be merged
if numel(varargin)>1
    % Two or more inputs
    if all(cellfun(@(x)(isa(x,'IX_mask')), varargin))
        n = cellfun(@numel, varargin);
        nend = cumsum(n);
        nbeg = nend - n + 1;
        mask_arr = repmat(IX_mask, [nend(end),1]);
        for i=1:numel(n)
            mask_arr(nbeg(i):nend(i)) = varargin{i}(:);
        end
    else
        error ('IX_mask:combine:invalid_argument',...
            'One or more input argument is not an IX_mask object')
    end
    
else
    % Single instance of IX_mask object (or would never have reached here)
    % but with at least two elements (or would have been caught at the 
    % beginning of this method)
    mask_arr = varargin{1};
end

% Create output IX_mask object
nel = arrayfun(@(x)(numel(x.msk)), mask_arr);
nend = cumsum(nel);
nbeg = nend - nel + 1;
msk = zeros(1,nend(end));
for i=1:numel(nel)
    msk(nbeg(i):nend(i)) = mask_arr(i).msk;
end

obj_out = IX_mask(msk);
