function A = object_elements (obj, varargin)
% Return selected object elements of a given array from the original set of arrays
%
%   >> A = object_elements (obj, iarray, ind)
%   >> A = object_elements (obj, ind)           % OK if only one original array
%
% Input:
% ------
%   obj         object_lookup object
%
%   iarray      Scalar index of the original object array from the
%              cell array of object arrays from which the object lookup
%              was created.
%               If there was only one object array, then iarray is not
%              necessary (as it assumed iarray=1)
%
%   ind         Array containing indices of objects in the original
%              object array referred to by iarray, from which to extract
%              elements. min(ind(:))>=1, max(ind(:))<=number of objects
%              in the object array selected by iarray
%
% Output:
% -------
%   A           Object array obtained by indexing elements ind from the
%              original array corresponding to index iarray


% Check validity
if ~isscalar(obj)
    error('HERBERT:object_lookup:invalid_argument', ...
        'Only operates on a single object_lookup (i.e. object must be scalar');
end
if ~obj.filled
    error('HERBERT:object_lookup:invalid_argument', ...
        'The object_lookup is not initialised')
end

% Get return argument
if numel(varargin)==2
    iarray = varargin{1};
    if ~isscalar(iarray)
        error('HERBERT:object_lookup:invalid_argument', ...
            'Index to original object array, ''iarray'', must be a scalar')
    end
    ind = varargin{2};
elseif numel(varargin)==1
    if numel(obj.indx_)==1
        iarray = 1;
        ind = varargin{1};
    else
        error('HERBERT:object_lookup:invalid_argument', ...
            'Must give index to the object array from which elements are to be recovered')
    end
else
    error('HERBERT:object_lookup:invalid_argument', ...
        'Invalid number of input arguments')
end

% Get return argument
% - indices to elements in object_store_ for the array with index iarray
%   Reshape to the original input array of the objects
indx = reshape(obj.indx_{iarray}, obj.sz_{iarray});   
% - Indices of the elements to extract
ix = indx(ind);
% - Extract elements, and reshape to size of ix because this is the shape the
%   output would have had we directly indexed into the original object array.
A = obj.object_store_(ix);
A = reshape(A, size(ix));

end
