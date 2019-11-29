function plist_new = multifit_gateway_parameter_set (plist, pnew)
% Set the numeric array of parameters in a valid parameter list
%
%   >> p = multifit_gateway_parameter_set (plist, p)
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
%               where p is a numeric vector with at least one element
%
%   pnew    New array to be placed at the root of the parameter list
%
% Output:
% -------
%   plist_new   New parameter list, with the new array reshaped as the
%               existing array if the number of elements are the same.
%
%
% This is a gateway routine to a private multifit function
 
 
% Original author: T.G.Perring 
% 
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $) 


plist_new = parameter_set (plist, pnew);
