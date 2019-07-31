function obj = set_bpin (obj, varargin)
% Set the initial values of background function parameters
%
% Set initial values for all background functions
%   >> obj = obj.set_bpin (pin)
%
% Set for one or more specific background function(s)
%   >> obj = obj.set_bpin (ifun, pin)
%
% Input:
% ------
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
%               >> obj = obj.set_bpin ([100,10,0.5])
%
%               fits the datasets independently to Gaussians starting
%               with the same initial parameters
%
%               >> obj = obj.set_bfun ({[100,10,0.5], [140,10,2]})
%
%               fits the datasets independently to Gaussians starting
%               with the different initial parameters
%
%           Note: If a subset of functions is selected with the optional
%          parameter ifun, then the expansion of a single parameter list
%          to an array applies only to that subset
%
% Optional argument:
%   ifun    Scalar or row vector of function indicies to which the operation
%          will be applied. [Default: all functions]
%
%
% See also set_pin set_bfun set_fun

% -----------------------------------------------------------------------------
% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_set_pin_intro = fullfile(mfclass_doc,'doc_set_pin_intro.m')
%
%   type = 'back'
%   pre = 'b'
%
% -----------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:> <doc_set_pin_intro> <type> <pre>
%
%
% See also set_pin set_bfun set_fun
% <#doc_end:>
% -----------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)


% Process input
isfore = false;
[ok, mess, obj] = set_pin_private_ (obj, isfore, varargin);
if ~ok, error(mess), end
