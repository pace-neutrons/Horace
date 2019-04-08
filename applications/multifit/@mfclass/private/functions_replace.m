function Sfun = functions_replace (Sfun_in, isfore, ind)
% Replace function(s) and parameter list(s) with defaults
%
%   >> Sfun = functions_replace (Sfun_in, isfore, 'all')
%   >> Sfun = functions_replace (Sfun_in, isfore, ind)
%
% Input:
% ------
%   Sfun_in Functions structure: fields are 
%               foreground_is_local_, fun_, pin_, np_, free_
%               background_is_local_, bfun_, bpin_, nbp_, bfree_
%
%   isfore  True if foreground functions, false if background functions
%   ind     Indicies of the functions to be replaced (row vector)
%           One index per functions, in the range
%               foreground functions:   1:(numel(Sfun.fun_)
%               background functions:   1:(numel(Sfun.bfun_)
%
% Output:
% -------
%   Sfun    Updated functions structure: fields are 
%               foreground_is_local_, fun_, pin_, np_, free_
%               background_is_local_, bfun_, bpin_, nbp_, bfree_
%
%
% In principle this function can just make a call to functions_insert
% followed by one to functions_insert, but the code here is so simple there
% is no advantage in doing so


% Original author: T.G.Perring
%
% $Revision:: 830 ($Date:: 2019-04-08 16:16:02 +0100 (Mon, 8 Apr 2019) $)


% Fill output with default structure
Sfun = Sfun_in;
if isnumeric(ind) && numel(ind)==0
    return
end

% Update properties
if ischar(ind) && strcmpi(ind,'all')
    if isfore
        n = numel(Sfun_in.fun_);
        Sfun.fun_  = cell(1,n);
        Sfun.pin_  = repmat(mfclass_plist(),1,n);
        Sfun.np_   = zeros(1,n);
        Sfun.free_ = repmat({true(1,0)},1,n);
    else
        n = numel(Sfun_in.bfun_);
        Sfun.bfun_  = cell(1,n);
        Sfun.bpin_  = repmat(mfclass_plist(),1,n);
        Sfun.nbp_   = zeros(1,n);
        Sfun.bfree_ = repmat({true(1,0)},1,n);
    end
elseif isnumeric(ind)
    if isfore
        change=false(1,numel(Sfun.fun_));
        change(ind)=true;
        n = sum(change);
        Sfun.fun_(change)  = cell(1,n);
        Sfun.pin_(change)  = repmat(mfclass_plist(),1,n);
        Sfun.np_(change)   = zeros(1,n);
        Sfun.free_(change) = repmat({true(1,0)},1,n);
    else
        change=false(1,numel(Sfun.bfun_));
        change(ind)=true;
        n = sum(change);
        Sfun.bfun_(change)  = cell(1,n);
        Sfun.bpin_(change)  = repmat(mfclass_plist(),1,n);
        Sfun.nbp_(change)   = zeros(1,n);
        Sfun.bfree_(change) = repmat({true(1,0)},1,n);
    end
else
    error('Logic error. Contact developers')
end
