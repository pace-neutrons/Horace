function ok = plist_parse (plist)
% Check that a plist has the correct format for a wrapper list. This is the
% the same as a conventional multifit parameter list ecept that the bottom
% lsit does not have a numeric parameter array:
%
%   >> [ok,np]=parameter_list_single_valid(plist)
%
% Input:
% ------
%   plist   Parameter list for a single function (can have zero number of parameters)
%
% Output:
% -------
%   ok      Status flag: =true if plist_in is valid; false otherwise
%   mess    Error message: ='' if OK, contains error message if not OK
%   np      Number of parameters in the numeric array
%
%
% A valid parameter list is one of the following:
%   - Empty argument
%   
%   - A cell array of constant parameters
%       e.g.  {c1, c2}
%
%   - A recursive nesting of functions and parameter lists:
%       p<n> = {@func<n-1>, plist<n-1>, c1<n>, c2<n>,...}
%            :
%       p<1> = {@func<0>, p<0>, c1<1>, c2<1>,...}
%       p<0> = {c1<0>, c2<0>,...}
%         or = <empty argument>
%
%     This defines a recursive form for the parameter list that it is assumed
%     the functions in argument func accept:
%       p<0> = <empty argument>
%         or = {c1<0>, c2<0>, ...}
%
%       p<1> = {@func<0>, p<0>, c1<1>, c1<2>,...}
%
%       p<2> = {@func<1>, {@func<0>, p<0>, c1<1>, c2<1>,...}, c1<2>, c2<2>,...}
%            :
%
% When recursively nesting functions and parameter lists, there can be any
% number of additional arguments c1, c2,... , including the case of no
% additional arguments.
% For example, the following are valid
%        []
%       {@myfunc}
%       {@myfunc1,{@myfunc}}

ok=false;

if iscell(plist) && numel(plist)>=2
    if isa(plist{1},'function_handle')
        ok=plist_parse_single(plist{2});
    else
        ok=true;
    end
elseif isnumeric(plist) && (isempty(plist) || (numel(size(plist))==2 && size(plist,1)==1))
    ok=true;
end
