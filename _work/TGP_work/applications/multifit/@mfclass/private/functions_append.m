function Sfun = functions_append (Sfun_in, isfore, n_append)
% Append default function handle(s) and parameter list(s)
%
%   >> Sfun = functions_append (Sfun_in, isfore, n)
%
% Input:
% ------
%   Sfun_in Functions structure: fields are 
%               foreground_is_local_, fun_, pin_, np_, free_
%               background_is_local_, bfun_, bpin_, nbp_, bfree_
%
%   isfore  True if foreground functions, false if background functions
%
%   n       Number of empty entries to append. Can be zero.
%
% Output:
% -------
%   Sfun    Updated functions structure: fields are 
%               foreground_is_local_, fun_, pin_, np_, free_
%               background_is_local_, bfun_, bpin_, nbp_, bfree_
%
%
% In principle this function can just make a call to functions_insert
% but the code here is so simple there is no advantage in doing so


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Fill output with default structure
Sfun = Sfun_in;
if n_append==0
    return
end

% Update properties
if isfore
    Sfun.fun_  = [Sfun.fun_, cell(1,n_append)];
    Sfun.pin_  = [Sfun.pin_, repmat(mfclass_plist(),1,n_append)];
    Sfun.np_   = [Sfun.np_, zeros(1,n_append)];
    Sfun.free_ = [Sfun.free_, repmat({true(1,0)},1,n_append)];
else
    Sfun.bfun_  = [Sfun.bfun_, cell(1,n_append)];
    Sfun.bpin_  = [Sfun.bpin_, repmat(mfclass_plist(),1,n_append)];
    Sfun.bnp_   = [Sfun.nbp_, zeros(1,n_append)];
    Sfun.bfree_ = [Sfun.bfree_, repmat({true(1,0)},1,n_append)];
end
