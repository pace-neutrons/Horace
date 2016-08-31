function p = parameter_get(plist)
% Get the numeric array of parameters in a valid parameter list as a column vector
%
%   >> p = parameter_get(plist)
%
% Input:
% ------
%   plist   Parameter list of the recursive form
%               plist<n> = {@func<n-1>, plist<n-1>, c1<n>, c2<n>,...}
%                        :
%               plist<1> = {@func<0>, plist<0>, c1<1>, c2<1>,...}
%               plist<0> = {p, c1<0>, c2<0>,...}
%                     or =  p
%
%               where p is a numeric vector (can contain no elements)
%
% Output:
% -------
%   p       The numeric array at the root of the parameter list,
%          returned as a column vector.
%           If no parameters, then returned as zeros(0,1))

if iscell(plist) && ~isempty(plist)
    if isa(plist{1},'function_handle')
        p=parameter_get(plist{2});
    else
        p=plist{1};
    end
else
    p=plist;
end

if ~isempty(p)
    if ~iscolvector(p)
        p=p(:);
    end
else
    p=zeros(0,1);     % column of zero length
end
