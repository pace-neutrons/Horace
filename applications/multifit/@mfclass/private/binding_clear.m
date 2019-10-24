function Scon = binding_clear (Scon_in, np_, nbp_, ipb, ifunb)
% Clear selected bound parameters
%
%   >> Scon = binding_clear (Scon_in, np_, nbp_, ipb, ifunb)
%
% If a parameter is not bound, it is ignored
%
% Input:
% ------
%   Scon_in Constraints structure: fields are 
%               bound_
%               bound_to_
%               ratio_
%               bound_to_res_
%               ratio_res_
%   np_     Array of number of foreground parameters in each function in the
%          underlying definition of the constraints structure (row vector)
%   nbp_    Array of number of background parameters in each function in the
%          underlying definition of the constraints structure (row vector)
%   ipb     Parameter indicies within the functions for the bound parameters
%          (column vector))
%   ifunb   Function indicies for the bound parameters (column vector):
%               foreground functions: numbered 1,2,3,...numel(np)
%               background functions: numbered -1,-2,-3,...-numel(nbp)
%
% Output:
% -------
%   Scon    Constraints structure on output: fields are 
%               bound_
%               bound_to_
%               ratio_
%               bound_to_res_
%               ratio_res_


% Original author: T.G.Perring
%
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)


% Fill output with default structure
Scon = Scon_in;

% Return if nothing to do
if numel(ipb)==0
    return
end

% Convert parameter indicies into linear list
ibnd = parfun2ind (ipb, ifunb, np_, nbp_);

% Clear parameters (note: user may have entered a parameter more than once 
% in the list, and ones that are not bound)
ibnd = ibnd(Scon.bound_(ibnd));     % parameters which are actually bound (may have repeats)   
ic = ismember(ibnd,nonzeros(Scon.bound_to_)); % true when a parameter is bound to one of ibnd

if ~any(ic)
    % None of the parameters to be cleared have a parameter bound to them - this is a simple case
    % as there is no chain of bound parameters to resolve
    Scon.bound_(ibnd) = false;
    Scon.bound_to_(ibnd) = 0;
    Scon.ratio_(ibnd) = 0;
    Scon.bound_to_res_(ibnd) = 0;
    Scon.ratio_res_(ibnd) = 0;
else
    % One or more parameters to be cleared have other(s) bound to them. Need to
    % resolve the bindings again
    Scon.bound_(ibnd) = false;
    Scon.bound_to_(ibnd) = 0;
    Scon.ratio_(ibnd) = 0;
    [Scon.bound_to_res_,Scon.ratio_res_,ok] = binding_resolve (Scon.bound_to_,Scon.ratio_);
    if ~ok, error('Logic error. Contact developers'), end   % should be OK - as started from a valid set
end
