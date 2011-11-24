function pnew = parameter_set (plist, p)
% Set the numeric vector of parameters in a valid parameter list of the recursive form:
%   plist' = {@func1, plist, d1, d2,...};  plist = {p, c1, c2,...}  or p  (p numeric vector)
%
if iscell(plist) && ~isempty(plist)
    if isa(plist{1},'function_handle')
        pnew={plist{1},parameter_set(plist{2},p),plist{3:end}};
    else
        pnew={p,plist{2:end}};
    end
else
    pnew=p;
end
