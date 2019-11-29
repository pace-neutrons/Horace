function A = object_array (obj, iarray)
% Return a given object array from the original set of arrays
%
%   >> obj = object_array (iarray)
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
    error('Only operates on a single object_lookup (i.e. object must be scalar');
end
if ~obj.filled
    error('The object_lookup is not initialised')
end

% Get return argument
A = obj.object_store_(obj.indx_{iarray});
A = reshape(A,obj.sz_{iarray});
