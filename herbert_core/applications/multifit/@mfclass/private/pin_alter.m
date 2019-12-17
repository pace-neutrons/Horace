function [Sfun, cleared] = pin_alter (Sfun_in, isfore, indfun, pin, np)
% Set function parameter lists
%
%   >> Sfun = pin_alter (Sfun_in, isfore, indfun)           % set to defaults
%   >> Sfun = pin_alter (Sfun_in, isfore, indfun, pin, np)
%
% If the number of numeric parameters is unchanged, then the fixed/free
% status of the parameters is unchanged (the most likely scenario is that
% the user is changing the initial starting values, and so would expect
% the same fixed/free status). If the number of numeric parameters is altered
% for a function, then the parameters are set to float.
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
%   pin     Array of mfclass_plist objects (row vector).
%          Length must be the same as indfun.
%   np      Array of number of parameters (row vector)
%          Length must be the same as indfun.
%
%   If not given, then assumes the indicated parameters are to be cleared
%
% Output:
% -------
%   Sfun    Functions structure on output: fields are
%               foreground_is_local_, fun_, pin_, np_, free_
%               background_is_local_, bfun_, bpin_, nbp_, bfree_
%   cleared Logical array of which functions in indfun had the number of numeric
%          parameters altered, and also the float status cleared (row vector)
%           Note: numel(cleared)=numel(indfun)
%
%
% It is assumed that the input is consistent with the information in Sfun_in
% i.e. the number of parameters for each function, the number of functions etc.


% Original author: T.G.Perring
%
% $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)


% Fill output with default structure
Sfun = Sfun_in;
if isempty(indfun)  % nothing to alter
    cleared = false(size(indfun));
    return
end

% Set optional arguments to the defaults
if ~exist('pin','var')
    pin = repmat(mfclass_plist(),size(indfun));
    np = zeros(size(indfun));
end

% Replace arrays, clearing the free/fixed status where the number of
% parameters has changed
if isfore
    clear = (np~=Sfun.np_(indfun));
    Sfun.pin_(indfun) = pin;
    Sfun.np_(indfun) = np;
    Sfun.free_(indfun(clear)) = mat2cell(true(1,sum(np(clear))),1,np(clear));
else
    clear = (np~=Sfun.nbp_(indfun));
    Sfun.bpin_(indfun) = pin;
    Sfun.nbp_(indfun) = np;
    Sfun.bfree_(indfun(clear)) = mat2cell(true(1,sum(np(clear))),1,np(clear));
end

cleared = clear;

