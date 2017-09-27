% Description of rgument bind as used by set_fun, set_bind, add_bind,
% and corresponding  methods for background functions
%
% -----------------------------------------------------------------------------
% <#doc_def:>
%   type   = '#1'    % 'back' or 'fore'
%   pre    = '#2'    % 'b' or ''
%   atype  = '#3'    % 'back' or 'fore' (opposite of type)
%   is_bind= '#4'    % true if the help for set_bind (cf set_fun) is being made
%   is_fun = '#5'    % opposite of is_pin
%
% -----------------------------------------------------------------------------
% <#doc_beg:>
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
%                   <type>ground parameter to be bound
%
%               [par, fun]                
%                   Parameter index and function index of the
%                   parameter to which the bound parameter is tied.
%                   The function index is positive for <type>ground
%                   functions, negative for <atype>ground functions.
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
%             The descriptor applies for all <type>ground functions, or if
%            the optional first input argument ifun is given to those
%            <type>ground functions
%
%               { ipar_bound, [ipar_free, ifun_free] }
%         *OR*  { ipar_bound, [ipar_free, ifun_free], ratio }
%
%           EXAMPLE
%               {2, [2,1]}  % bind parameter 2 of every <type>ground function
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
%               {[2,3], 6}  % bind parameter 2 of <type>ground function 3
%                           % to parameter 6 of the same function
% 
%           - Both ifun_bound and ifun_free missing:
%             --------------------------------------
%             Combines the above two cases: the descriptor applies for all
%            <type>ground functions (or those functions given by the
%            optional argument ifun described below), and that the unbound
%            parameter has the same  function index as the bound parameter
%            in each instance
%
%               { ipar_bound, ipar_free }
%         *OR*  { ipar_bound, ipar_free, ratio }
%
%           EXAMPLE
%               {2,5}       % bind parameter 2 to parameter 5 of the same 
%                           % function, for every <type>ground function
% <#doc_end:>
% -----------------------------------------------------------------------------