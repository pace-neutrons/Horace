function obj = set_bbind (obj,varargin)
% Set bindings of background parameters to back- &/or foreground parameters
%
% Set one or more bindings
%   >> obj = obj.set_bbind (bind)
%   >> obj = obj.set_bbind (b1, b2, b3...)
%
% Set one or more bindings for one or more specific background function(s)
%   >> obj = obj.set_bbind (ifun, bind)
%   >> obj = obj.set_bbind (ifun, b1, b2, b3...)
%
% Input:
% ------
%   bind    Binding of one or more parameters to other parameters.
%           In general, bind has the form:
%               {b1, b2, ...}
%           where b1, b2 are binding descriptors.
%
%           Each binding descriptor is a cell array with the form:
%               { [ipar_bound, ifun_bound], [ipar_free, ifun_free] }
%         *OR*  { [ipar_bound, ifun_bound], [ipar_free, ifun_free], ratio }
%
%           where
%               [ipar_bound, ifun_bound]
%                   Parameter index and function index of the
%                   background parameter to be bound
%
%               [ipar_free, ifun_free]
%                   Parameter index and function index of the
%                   parameter to which the bound parameter is tied.
%                   The function index is positive for background
%                   functions, negative for foreground functions.
%
%               ratio
%                   Ratio of bound parameter value to floating
%                   parameter. If not given, or ratio=NaN, then the
%                   ratio is set from the initial parameter values
%
%           Binding descriptors that set multiple bindings
%           ----------------------------------------------
%           If ifun_bound and/or ifun_free are omitted a binding
%          descriptor has a more general interpretation that makes it
%          simple to specify bindings for many functions:
%
%           - ifun_bound missing:
%             -------------------
%             The descriptor applies for all background functions, or if
%            the optional first input argument ifun is given to those
%            background functions
%
%               { ipar_bound, [ipar_free, ifun_free] }
%         *OR*  { ipar_bound, [ipar_free, ifun_free], ratio }
%
%           EXAMPLE
%               {2, [2,1]}  % bind parameter 2 of every background function
%                           % to parameter 2 of the first function
%                           % (Effectively makes parameter 2 global)
%
%           - ifun_free missing:
%             ------------------
%             The descriptor assumes that the unbound parameter has the same
%            function index as the bound parameter
%
%               { [ipar_bound, ifun_bound], ipar_free }
%         *OR*  { [ipar_bound, ifun_bound], ipar_free, ratio }
%
%           EXAMPLE
%               {[2,3], 6}  % bind parameter 2 of background function 3
%                           % to parameter 6 of the same function
%
%           - Both ifun_bound and ifun_free missing:
%             --------------------------------------
%             Combines the above two cases: the descriptor applies for all
%            background functions (or those functions given by the
%            optional argument ifun described below), and that the unbound
%            parameter has the same  function index as the bound parameter
%            in each instance
%
%               { ipar_bound, ipar_free }
%         *OR*  { ipar_bound, ipar_free, ratio }
%
%           EXAMPLE
%               {2,5}       % bind parameter 2 to parameter 5 of the same
%                           % function, for every background function
%
% Optional argument:
%   ifun    Scalar or row vector of function indicies to which the operation
%          will be applied. [Default: all functions]
%
%
% See also add_bbind set_bfun set_bind add_bind set_fun

% -----------------------------------------------------------------------------
% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_set_bind_intro = fullfile(mfclass_doc,'doc_set_bind_intro.m')
%
%   type = 'back'
%   pre = 'b'
%   atype = 'fore'
%   func  = 'set'
%
% -----------------------------------------------------------------------------
% <#doc_beg:> multifit
% Set bindings of <type>ground parameters to <type>- &/or <atype>ground parameters
%
%   <#file:> <doc_set_bind_intro> <type> <pre> <atype> <func>
%
%
% See also add_bbind set_bfun set_bind add_bind set_fun
% <#doc_end:>
% -----------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)


% Process input
% -------------
isfore = false;

% Clear all bindings first
[ok, mess, obj] = clear_bind_private_ (obj, isfore, {'all'});
if ~ok, error(mess), end

% Add new bindings
[ok, mess, obj] = add_bind_private_ (obj, isfore, varargin);
if ~ok, error(mess), end
