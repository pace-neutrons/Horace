function tf = isequalnArr(A)
% Determine equality between array elements, treating NaN values as equal
%
%   >> tf = isequalnArr(A)
%
% Performs the function as the Matlab intrinsic isequaln but for an array
%
% Input:
% ------
%   A       Array. Particularly suited to struct or object arrays with a
%          limited array size but complex internal structure.
%           WARNING: Will be very inefficient on large numeric, logical or
%          character arrays,
%
% Output:
% -------
%   tf      True if all elements of the array are equal

tf = true;
for i=2:numel(A)
    if ~isequaln(A(i-1),A(i))
        tf = false;
        return
    end
end
