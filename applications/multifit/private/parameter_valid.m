function [ok,np]=parameter_valid(plist)
% Check if form of parameter object is a valid parameter list of the recursive form:
%   plist<n+1> = {@func<n>, plist<n>, cn_1, cn_2,...};  
%
%   plist<0> = {p, c0_1, c0_2,...}  or p , where p is a numeric vector
%
% Return the number of parameters in the numeric vector.
%
% Defines a recursive form for the parameter list:
%   plist<0> = p               numeric vector
%         or ={p, c1, c2, ...} cell array, with first parameter a numeric vector
%
%   plist<1> = {@func<0>, plist<0>, c1_1, c1_2,...}
%
%   plist<2> = {@func<1>, {@func<0>, plist<0>, c1_1, c1_2,...}, c2_1, c2_2,...}
%          :
%
% NOTES:
%  - Insists that there is at least one parameter in the numeric array 
%    i.e. the vector cannot be empty.
%  - The outer constants cn_1, cn_2, ... of plist are used as constants to the
%    function given elsewhere.

ok=false;
np=[];
if iscell(plist) && ~isempty(plist)
    if isa(plist{1},'function_handle')
        [ok,np]=parameter_valid(plist{2});
    elseif isvector(plist{1}) && isnumeric(plist{1}) && numel(plist{1})>0
        ok=true;
        np=numel(plist{1});
    end
elseif isvector(plist) && isnumeric(plist) && numel(plist)>0
    ok=true;
    np=numel(plist);
end
