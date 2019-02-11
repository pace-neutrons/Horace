function ind=array_keep(arr,vals)
% Find the indicies of elements of an array that do NOT appear in a list of test values
%
%   >> ind=array_keep(arr,vals)
%
% Input:
% ------
%   arr     Numerical array, cell array of strings, or array of structures
%          (where each field is numeric or logical array, or string).
%           Need not contain unique elements.
%
%   vals    List of test values of the same type (need not be unique)
%
% Output:
% -------
%   ind     indicies of elements of arr that do not appear in vals

% Get indicies of elements that do appear in list of values
ind=array_filter(arr,vals);
keep=true(size(arr));
keep(ind)=false;
ind=find(keep);
