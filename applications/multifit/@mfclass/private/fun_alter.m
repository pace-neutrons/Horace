function [Sfun, cleared] = fun_alter (Sfun_in, isfore, indfun, fun)
% Set function handles
%
%   >> Sfun = fun_alter (Sfun_in, isfore, indfun)       % Set to defaults
%   >> Sfun = fun_alter (Sfun_in, isfore, indfun, fun)
%
% If the a function handle replaced with a different function handle or
% empty function (recall [] means 'no function'), then the parameter list 
% and float status are set to the default empty values.
% If a function handle is set to the same value, then the parameters and
% float status are left unchanged.
%
% Input:
% ------
%   Sfun_in Functions structure: fields are
%               foreground_is_local_, fun_, pin_, np_, free
%               background_is_local_, bfun_, bpin_, nbp_, bfree
%   isfore  True if foreground functions, false if background functions
%   indfun  Row vector if indicies of functions to which elements of
%          pin refer. Can be empty.
%
% Optional:
%   fun     Cell array of function handles (an element is [] for a missing
%          function) (row vector). Length must be the same as indfun.
%           If not given, sets the functions and other parameters for the
%          functions indicated by indfun to the defaults
%
% Output:
% -------
%   Sfun    Functions structure on output: fields are
%               foreground_is_local_, fun_, pin_, np_, free_
%               background_is_local_, bfun_, bpin_, nbp_, bfree_
%   cleared Logical array of which functions in indfun were actually altered
%          The corresponding parameter lists and float status will have been
%          cleared (row vector) 
%           Note: numel(cleared)=numel(indfun)
%           Note: cleared is also true if and only if the number of parameters
%                 has been changed or was already zero. It is therefore 
%                 useful to determine if the constraints structure needs to be
%                 updated
%
%
% It is assumed that the input is consistent with the information in Sfun_in
% i.e. the number of parameters for each function, the number of functions etc.


% Original author: T.G.Perring
%
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)


% Fill output with default structure
Sfun = Sfun_in;
if isempty(indfun)  % nothing to alter
    cleared = false(size(indfun));
    return
end

% Set optional argument to the default
if ~exist('fun','var')
    fun = repmat({[]},size(indfun));
end

% Replace functions, clearing the parameters and free/fixed status
% parameters where the function handle is empty
if isfore
    clear = ~cellfun(@(x,y)isequal(x,y),fun,Sfun.fun_(indfun));
    Sfun.fun_(indfun) = fun;
    Sfun.pin_(indfun(clear)) = mfclass_plist();
    Sfun.np_(indfun(clear)) = 0;
    Sfun.free_(indfun(clear)) = {true(1,0)};
else
    clear = ~cellfun(@(x,y)isequal(x,y),fun,Sfun.bfun_(indfun));
    Sfun.bfun_(indfun) = fun;
    Sfun.bpin_(indfun(clear)) = mfclass_plist();
    Sfun.nbp_(indfun(clear)) = 0;
    Sfun.bfree_(indfun(clear)) = {true(1,0)};
end

cleared = clear;
