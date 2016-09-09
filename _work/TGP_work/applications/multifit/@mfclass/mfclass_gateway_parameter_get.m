function p = mfclass_gateway_parameter_get(dummy, plist)
% Get the numeric array of parameters in a valid parameter list
%
%   >> p = mfclass_gateway_parameter_get (dummy, plist)
%
% Input:
% ------
%   dummy   Dummy object of class mfclass, to force the call of this method
%   plist   Parameter list of the recursive form
%               plist<n> = {@func<n-1>, plist<n-1>, c1<n>, c2<n>,...}
%                        :
%               plist<1> = {@func<0>, plist<0>, c1<1>, c2<1>,...}
%               plist<0> = {p, c1<0>, c2<0>,...}
%                     or =  p
%
%               where p is a numeric vector with at least one element
%
% Output:
% -------
%   p       The numeric array at the root of the parameter list,
%          returned as a column vector

% Fixup to make a gateway routine to a private multifit function

p = parameter_get(plist);
