function ind=array_keep(arr,vals)
% Find the indicies of elements of an array that do NOT appear in a list of values
% Works for cell arrays of strings too
%
%   >> ind=array_remove(arr,vals)
%
%   arr     need not contain unique values
%   vals    list of test values (need not be unique)
%
%   ind     indicies of elements of arr that do not appear in vals

% Get indicies of elements that do appear in list of values
ind=array_filter(arr,vals);
keep=true(size(arr));
keep(ind)=false;
ind=find(keep);
