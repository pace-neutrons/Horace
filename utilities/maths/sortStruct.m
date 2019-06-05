function [bStruct, ix] = sortStruct(aStruct, varargin)
% Sort a one-dimensional struct array
%
%   >> [bStruct index] = sortStruct(aStruct)
%   >> [bStruct index] = sortStruct(aStruct, fieldNams)
%   >> [bStruct index] = sortStruct(..., directions)
%
% The function returns a nested sort of a (one-dimensional) struct array
% (aStruct), and can also return an index vector. The fields by which to sort are
% specified in a cell array of strings fieldNams. Fields must be numeric
% arrays, logical arrays, or character arrays (usually simple strings).
%
% Similar to the intrinsic Matlab sort but here for a struct array
%
% For a more general sorting algorithm that recursively resolves any objects
% into its properties and which can sort variable types of dissimilar 
% types and sizes, use <a href="matlab:help('gensort');">gensort</a>
%
% Input
% -----
%   aStruct     One-dimensional struct array (row or column)
%               The fields must be character arrays, or numeric or logical arrays
%
%   fieldNams   [Optional] name of one or more fields by which to sort the
%               structure. Single character string, or cell array of charaxter
%               strings. The structure is sorted according to the first field
%               name, then, for equal values for that field, by the second field
%               name etc.
%               Default: all fields as returned by the matlab intrinsic function
%               fieldnames
%
%   directions  [Optional] Specify whether the struct array should be sorted
%               in ascending or descending order for the fields.
%               Default: the struct array will be sorted in ascending order
%               for each field.
%
%               If supplied, directions must be:
%               - a single  1 to sort in ascending order for all fields, or
%               - a single -1 to sort in descending order for all fields, or
%               - a vector of 1's and -1's, the same length as fieldNams,
%                 where the struct array will be sorted in the order specified
%                 by directions(ii) for fieldNams(ii).
%
% Output:
% -------
%   bStruct     Sorted structure with same shape as input struct array
%
%   index       Index array with the same size as aStruct. Therefore
%               because aStruct is a vector, bStruct = aStruct(index)


if ~isstruct(aStruct), error('Function only sorts structure arrays'), end
if ~isvector(aStruct), error('Structure array must be a row or column vector'), end

% Perform sort
if ~isequalnArr(aStruct)
    [bStruct, ix] = sortStruct_private(aStruct, varargin{:});
else
    bStruct = aStruct;
    ix = reshape(1:numel(aStruct),size(aStruct));
end
