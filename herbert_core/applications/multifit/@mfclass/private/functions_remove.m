function Sfun = functions_remove (Sfun_in, isfore, ind)
% Remove function handle(s) and parameter list(s)
%
%   >> Sfun = functions_remove (Sfun_in, isfore, 'all')
%   >> Sfun = functions_remove (Sfun_in, isfore, ind)
%
% Input:
% ------
%   Sfun_in Functions structure: fields are
%               foreground_is_local_, fun_, pin_, np_, free_
%               background_is_local_, bfun_, bpin_, nbp_, bfree_
%
%   isfore  True if foreground functions, false if background functions
%
%   ind     Indicies of the functions to be removed (row vector)
%           One index per functions, in the range
%               foreground functions:   1:(numel(Sfun.fun_)
%               background functions:   1:(numel(Sfun.bfun_)
%           If empty (i.e. []), then nothing is done
%           For all functions of the type set by isfore, , set ind to 'all'
%
% Output:
% -------
%   Sfun    Updated functions structure: fields are
%               foreground_is_local_, fun_, pin_, np_, free_
%               background_is_local_, bfun_, bpin_, nbp_, bfree_


% Original author: T.G.Perring
%
% $Revision:: 838 ($Date:: 2019-12-05 14:56:03 +0000 (Thu, 5 Dec 2019) $)


% Fill output with default structure
Sfun = Sfun_in;
if isnumeric(ind) && numel(ind)==0
    return
end

% Update properties
if ischar(ind) && strcmpi(ind,'all')
    if isfore
        Sfun.fun_  = cell(1,0);
        Sfun.pin_  = repmat(mfclass_plist(),1,0);
        Sfun.np_   = zeros(1,0);
        Sfun.free_ = cell(1,0);
    else
        Sfun.bfun_  = cell(1,0);
        Sfun.bpin_  = repmat(mfclass_plist(),1,0);
        Sfun.nbp_   = zeros(1,0);
        Sfun.bfree_ = cell(1,0);
    end
elseif isnumeric(ind)
    if isfore
        ok=true(1,numel(Sfun.fun_));
        ok(ind)=false;
        Sfun.fun_  = Sfun.fun_(ok);
        Sfun.pin_  = Sfun.pin_(ok);
        Sfun.np_   = Sfun.np_(ok);
        Sfun.free_ = Sfun.free_(ok);
    else
        ok=true(1,numel(Sfun.bfun_));
        ok(ind)=false;
        Sfun.bfun_  = Sfun.bfun_(ok);
        Sfun.bpin_  = Sfun.bpin_(ok);
        Sfun.nbp_   = Sfun.nbp_(ok);
        Sfun.bfree_ = Sfun.bfree_(ok);
    end
else
    error('Logic error. Contact developers')
end

