function [ok,cout,all_non_empty]=str_make_cellstr_trim(varargin)
% Take a set of arguments and try to make a cellstr of non-empty strings from the contents
%
%   >> [ok,cout,all_non_empty] = str_make_cellstr(c1,c2,c3,...)
%
% Input:
% ------
%   c1,c2,c3,...    Two-dimensional character arrays or cell arrays of strings
%
% Output:
% -------
%   ok              =true if valid input (could all be empty)
%   cout            Column vector cellstr, with empty entries removed.
%   all_non_empty   True if all input strings are non-empty

[ok,cout]=str_make_cellstr(varargin{:});
if ok
    [cout,all_non_empty]=str_trim_cellstr(cout);
else
    all_non_empty=false;
end
