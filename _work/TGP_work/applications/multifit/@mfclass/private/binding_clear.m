function obj = binding_clear (obj_in, np_, nbp_, ipb, ifunb)
% Clear selected bound parameters
%
%   >> obj = binding_clear (obj_in, np_, nbp_, ipb, ifunb)
%
% If a parameter is not bound, it is ignored
%
% Input:
% ------
%   obj_in  Constraints structure: fields are 
%               free_
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
%   obj     Constraints structure on output: fields are 
%               free_
%               bound_
%               bound_to_
%               ratio_
%               bound_to_res_
%               ratio_res_


% Fill output with default structure
obj = obj_in;

% Return if nothing to do
if numel(ipb)==0
    return
end

% Convert parameter indicies into linear list
ibnd = parfun2ind (ipb, ifunb, np_, nbp_);

% Clear parameters (note: user may have entered a parameter more than once 
% in the list, and ones that are not bound)
ibnd = ibnd(obj.bound_(ibnd));     % parameters which are actually bound (may have repeats)   
ic = ismember(ibnd,nonzeros(obj.bound_to_)); % true when a parameter is bound to one of ibnd

if ~any(ic)
    % None of the parameters to be cleared have a parameter bound to them - this is a simple case
    % as there is no chain of bound parameters to resolve
    obj.bound_(ibnd) = false;
    obj.bound_to_(ibnd) = 0;
    obj.ratio_(ibnd) = 0;
    obj.bound_to_res_(ibnd) = 0;
    obj.ratio_res_(ibnd) = 0;
else
    % One or more parameters to be cleared have other(s) bound to them. Need to
    % resolve the bindings again
    obj.bound_(ibnd) = false;
    obj.bound_to_(ibnd) = 0;
    obj.ratio_(ibnd) = 0;
    [obj.bound_to_res_,obj.ratio_res_,ok] = binding_resolve (obj.bound_to_,obj.ratio_);
    if ~ok, error('Logic problem - contact T.G.Perring'), end   % should be OK - as started from a valid set
end
