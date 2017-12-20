% Description of argument pin as used by set_fun, set_pin,
% and corresponding methods for background functions
%
% -----------------------------------------------------------------------------
% <#doc_def:>
%   type   = '#1'    % 'back' or 'fore'
%   pre    = '#2'    % 'b' or ''
%   is_pin = '#3'    % true if the help for set_pin (cf set_fun) is being made
%   is_fun = '#4'    % opposite of is_pin
%
% -----------------------------------------------------------------------------
% <#doc_beg:>
%   pin     Initial parameter list or a cell array of initial parameter
%          lists. Depending on the function, the form of the parameter
%          list is either:
%               p
%          or:
%               {p,c1,c2,...}
%          where
%               p           A vector of numeric parameters that define
%                          the function (e.g. [A,x0,w] as area, position
%                          and width of a peak)
%               c1,c2,...   Any further constant arguments needed by the
%                          function e.g. the filenames of lookup tables)
%
%           In general:
%           - If the fit function is global, then give only one parameter
%             list: the one function applies to every dataset
%
%           - If the fit functions are local, then:
%               - if every dataset is to be fitted to the same function
%                and with the same initial parameter values, you can 
%                give just one parameter list. The parameters will be
%                fitted independently (subject to any bindings that
%                can be set elsewhere)
%
%               - if the functions are different for different datasets
%                or the intiial parmaeter values are different, give a
%                cell array of function handles, one per dataset
%
%           This syntax allows an abbreviated argument list. For example,
%          if there are two datsets and the fit functions are local then:
%
%           <is_fun:>
%               >> obj = obj.set_<pre>fun (@gauss, [100,10,0.5])
%           <is_fun/end:>
%           <is_pin:>
%               >> obj = obj.set_<pre>pin ([100,10,0.5])
%           <is_pin/end:>
%
%               fits the datasets independently to Gaussians starting
%               with the same initial parameters
%
%           <is_fun:>
%               >> obj = obj.set_<pre>fun (@gauss, {[100,10,0.5], [140,10,2]})
%           <is_fun/end:>
%           <is_pin:>
%               >> obj = obj.set_<pre>fun ({[100,10,0.5], [140,10,2]})
%           <is_pin/end:>
%
%               fits the datasets independently to Gaussians starting
%               with the different initial parameters
%               
%           Note: If a subset of functions is selected with the optional
%          parameter ifun, then the expansion of a single parameter list
%          to an array applies only to that subset
% <#doc_end:>
% -----------------------------------------------------------------------------