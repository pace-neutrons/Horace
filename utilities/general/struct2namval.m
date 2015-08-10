function c=struct2namval(s)
% Covert structure to cell array of name1,val1,name2,val2,...
%
%   >> c=struct2namval(s)
%
% Input:
% ------
%   s   Structure (must be scalar)
%
% Output:
% -------
%   c   Cell array (row vector) of names and fields of s:
%           {name1,field1,name2,field2,...}

c=make_row([fieldnames(s),struct2cell(s)]);
