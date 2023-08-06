function A = object_array (obj, varargin)
% Return a given object array from the original set of arrays
%
%   >> obj = object_array (obj, iarray)
%   >> obj = object_array (obj)             % OK if only one original array
%
% Input:
% ------
%   obj         object_lookup object
%
%   iarray      Scalar index of the original object array from the
%              cell array of object arrays from which the object lookup
%              was created.
%
% Output:
% -------
%   A           Original object array corresponding to index iarray


% Check validity
if ~isscalar(obj)
    error('HERBERT:object_lookup:invalid_argument', 'Only operates on a single object_lookup (i.e. object must be scalar');
end
if ~obj.filled
    error('HERBERT:object_lookup:invalid_argument', 'The object_lookup is not initialised')
end

% Get return argument
if numel(varargin)==1
    iarray = varargin{1};
    if ~isscalar(iarray)
        error('HERBERT:object_lookup:invalid_argument', 'Index to original object array, ''iarray'', must be a scalar')
    end
elseif numel(varargin)==0
    if numel(obj.indx_)==1
        iarray = 1;
    else
        error('HERBERT:object_lookup:invalid_argument', 'Must give index to the object array that is to be retrieved')
    end
else
    error('HERBERT:object_lookup:invalid_argument', 'Invalid number of input arguments')
end

if iarray <= numel(obj.indx_)
    A = obj.object_store_(obj.indx_{iarray});
    A = reshape(A,obj.sz_{iarray});
else
    error('HERBERT:object_lookup:invalid_argument', 'Array index out of range')
end

end
