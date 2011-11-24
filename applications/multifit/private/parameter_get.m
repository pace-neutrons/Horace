function p=parameter_get(plist)
% Get the numeric vector of parameters in a valid parameter list of the recursive form:
%   plist' = {@func1, plist, d1, d2,...};  plist = {p, c1, c2,...}  or p  (p numeric vector)
%
if iscell(plist) && ~isempty(plist)
    if isa(plist{1},'function_handle')
        p=parameter_get(plist{2});
    else
        p=plist{1};
    end
else
    p=plist;
end
