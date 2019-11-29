function [bObj,ix]=sortObj(aObj)
% Sort an object array according to the public object properties
%
%   >> [bObj, ix] = sortObj(aObj)
%
% Similar to the intrinsic Matlab sort but here for an object array
%
% The sort is performed on the public properties of the object.
% For an equivalent method on the independent properties (hidden and public)
% use <a href="matlab:help('sortObjIndep');">sortObjIndep</a>.
%
% The properties must be must be numeric arrays, logical arrays, or character
% arrays.
%
% For a more general sorting algorithm that recursively resolves any objects
% into its properties and which can sort variable types of dissimilar
% types and sizes, use <a href="matlab:help('gensort');">gensort</a>
%
% Input:
% ------
%   aObj    Object array to be sorted (row or column vector)
%           The properties must be must be numeric arrays, logical arrays,
%          or character arrays
%
% Output:
% -------
%   bObj    Sorted object array. Same shape as aObj
%   ix      Index array with the same size as aObj, so bObj = aObj(ix)


if ~isobject(aObj), error('Function only sorts object arrays'), end
if ~isvector(aObj), error('Object array must be row or column vector'), end

% Perform sort
if ~isequalnArr(aObj)
    [~,ix] = sortStruct_private(structArrPublic(aObj));
    bObj = aObj(ix);
else
    bObj = aObj;
    ix = reshape(1:numel(aObj),size(aObj));
end
