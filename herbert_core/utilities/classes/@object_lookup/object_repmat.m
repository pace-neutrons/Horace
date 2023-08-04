function obj_out = object_repmat (obj, varargin)
% Return a given object array from the original set of arrays
%
% Apply to a specific array or set of arrays in in the object_lookup:
%   >> obj_out = object_repmat (obj, iarray, '-repeat', sz_repmat)
%
% Apply to the whole object_lookup:
%   >> obj_out = object_repmat (obj, '-repeat', sz_repmat)
%
% Input:
% ------
%   obj         object_lookup object containing one or more object arrays
%
%   iarray      Index or array of indices of object arrays to which to apply an
%               implicit repmat operation. If not given, the operation is
%               applied to all stored object arrays i.e. iarray = (1:obj.narray)
%
%   sz_repmat   One of:
%                 - The size of a single array:   sz
%                 - A cell array of array sizes: {sz1,sz2,...szN}
%
%               by which to implicitly replicate the subset of object arrays
%               indicated by the input argument iarray using the Matlab function
%               repmat. Here N is the number of indices in iarray.
%
%               The input object arrays are implicitly expanded as follows:
%                 - single array size:
%                       objArr1 => repmat(objArr1, sz)
%                       objArr2 => repmat(objArr2, sz)
%                           :               :
%                 - cell array of array sizes:
%                       objArr1 => repmat(objArr1, sz1)
%                       objArr2 => repmat(objArr2, sz2)
%                           :               :
%               The arguments sz (or sz1, sz2,...) must be valid single argument
%               input to the Matlab intrinsic function repmat i.e.               
%               - Valid array size from the Matlab function called size i.e. row
%                 vectors of at least two integers all of which must be greater
%                 than or equal to zero.
%               - A single positive integer n greater than or equal to zero.
%                 This is equivalent to size vector [n,n].
%
%               NOTE:
%               -----
%               In the case when there is only one object_array in the
%               object_lookup and sz_repmat is a cell array {sz1,sz2,...szN},
%               the number of stored arrays is increased from 1 to N, with the
%                   1st: repmat(objArr, sz1)
%                   2nd: repmat(objArr, sz2)
%                           :
%                   Nth: repmat(objArr, szN)
%
%               This provides a mechanism to create an object_lookup with many
%               identical stored arrays without the overhead of potentially
%               expensive multiple checks of object equivalence
%
%               EXAMPLE (assuming obj contains just one object array)
%                   object_repmat (obj, '-repeat', {1,1,1,1,1})
%
%
% Output:
% -------
%   obj_out     Output obj_lookup object


% Check validity of object_array
% ------------------------------
if ~isscalar(obj)
    error('HERBERT:object_lookup:invalid_argument', ...
        'Only operates on a single object_lookup (i.e. object must be scalar');
end
if ~obj.filled
    error('HERBERT:object_lookup:invalid_argument', ...
        'The object_lookup is not initialised')
end

% Parse input
% -----------
% Determine number and type OK
narg = numel(varargin);
if ~(narg==2 || narg==3) || ~ischar(varargin{end-1})
    error('HERBERT:object_lookup:invalid_argument', ...
        'Invalid number or type of input argument(s)')
end

% Get iarray
if narg==3
    if ~is_integer_id (varargin{1}) || max(varargin{1})>obj.narray
        error('HERBERT:object_lookup:invalid_argument', ...
            'Index array must be contain unique integers in the range 1-%d', obj.narray)
    end
    iarray = varargin{1}(:);    % column vector
else
    iarray = (1:obj.narray)';   % column vector
end

% Get sz_repmat
keyword = varargin{end-1};
if numel(keyword)<2 || ~strncmpi(keyword, '-repeat', numel(keyword))
    error('HERBERT:object_lookup:invalid_argument', ...
        'Unrecognised keyword option %s', keyword)
end
sz_repmat = parse_sz_repmat (varargin{end}, numel(iarray), obj.narray); % col vector


% Expand arrays
% -------------
% Get indexing arrays and sizes of stored arrays
sz = obj.sz_;
indx = obj.indx_;

% Reshape the index arrays to the sizes of the object arrays to which repmat
% will be applied
sz_sel = sz(iarray);
indx_sel = cellfun (@(x,y)reshape(x,y), indx(iarray), sz_sel, 'uniformoutput', false);
 
% Now repmat the index and sz arrays as required, turning the indexd arrays back
% into column vectors as the object definition requires
if numel(iarray) > 1
    if numel(sz_repmat)>1
        sz(iarray) = cellfun(@(x,y)size_repmat(x,y), sz_sel, sz_repmat,...
            'uniformOutput', false);
        indx(iarray) = cellfun(@(x,y)reshape((repmat(x,y)),[],1), indx_sel, sz_repmat,...
            'uniformOutput', false);
    else
        sz(iarray) = cellfun(@(x)size_repmat(x,sz_repmat{1}), sz_sel,...
            'uniformOutput', false);
        indx(iarray) = cellfun(@(x)reshape(repmat(x,sz_repmat{1}),[],1), indx_sel,...
            'uniformOutput', false);
    end
else
    if numel(sz_repmat)>1
        % This case increases the number of stored object arrays from 1 to
        % numel(sz_repmat). Therefore simply reassign sz and indx
        sz = cellfun(@(x)size_repmat(sz{1},x), sz_repmat,...
            'uniformOutput', false);
        indx = cellfun(@(x)reshape(repmat(indx_sel{1},x),[],1), sz_repmat,...
            'uniformOutput', false);
    else
        sz{iarray} = size_repmat(sz{1},sz_repmat{1});
        indx{iarray} = reshape(repmat(indx_sel{1},sz_repmat{1}),[],1);
    end
end

obj_out = obj;
obj_out.indx_ = indx;
obj_out.sz_ = sz;

end


%--------------------------------------------------------------------------
function sz_out = size_repmat (sz, sz_repmat)
% Return the size of the array that would be output by using repmat
%
%   >> sz_out = size_repmat (sz, sz_repmat)
%
% sz_out is the size of the array A_out obtained by the function call:
%   >> A_out = repmat (A, sz_repmat)
%
% where sz = size(A). sz_repmat is a scalar or a row vector with length >= 2


if numel(sz_repmat)==1
    sz_repmat = [sz_repmat,sz_repmat];
end
n1 = numel(sz);
n2 = numel(sz_repmat);
if n1>n2
    sz_out = [sz(1:n2).*sz_repmat, sz(n2+1:end)];
elseif n1<n2
    sz_out = [sz.*sz_repmat(1:n1), sz_repmat(n1+1:end)];
else
    sz_out = sz.*sz_repmat;
end

end
