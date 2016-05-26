function obj = constraints_append (obj_in, np_, nbp_, np, nbp)
% Extend constraints properties arrays to hold appended parameter data
%
%   >> obj = constraints_append (obj_in, np_, nbp_, np, nbp)
%
% Input:
% ------
%   obj_in  Constraints structure: fields are 
%               free_
%               bound_
%               bound_to_
%               ratio_
%               bound_from_
%   np_     Array of number of foreground parameters in each function in the
%          underlying definition of the constraints structure (row vector)
%   nbp_    Array of number of background parameters in each function in the
%          underlying definition of the constraints structure (row vector)
%   np      Number of foreground parameters in each function to append (row vector)
%   nbp     Number of background parameters in each function to append (row vector)
%
% Output:
% -------
%   obj     Constraints structure on output: fields are 
%               free_
%               bound_
%               bound_to_
%               ratio_
%               bound_from_
%
%
% In principle this function can be replaced by a call to constraints_insert_,
% but the case of append is much faster if done by a simple function.


obj = obj_in;

dnptot = sum(np);
dnbptot = sum(nbp);
if dnptot==0 && dnbptot==0  % trivial case of no changes
    return
end

nptot = sum(np_);
nbptot = sum(nbp_);
ntot = nptot + nbptot;

Nptot = nptot + dnptot;
Nbptot = nbptot + dnbptot;
Ntot = Nptot + Nbptot;

obj.free_ = [obj.free_(1:nptot); true(dnptot,1),...
    obj.free_(1:nbptot); true(dnbptot,1)];

obj.bound_ = [obj.bound_(1:nptot); false(dnptot,1),...
    obj.bound_(1:nbptot); false(dnbptot,1)];

obj.bound_to_ = [obj.bound_to_(1:nptot); zeros(dnptot,1),...
    obj.bound_to_(1:nbptot); zeros(dnbptot,1)];

obj.ratio_ = [obj.ratio_(1:nptot); NaN(dnptot,1),...
    obj.ratio_(1:nbptot); NaN(dnbptot,1)];

bound_from = sparse ([],[],[], Ntot, Ntot, Ntot);
bound_from(1:nptot,1:nptot) = obj.bound_from_(1:nptot,1:nptot);
bound_from(Nptot+1:Nptot+nbptot,Nptot+1:Nptot+nbptot) = obj.bound_from_(nptot+1:ntot,nptot+1:ntot);
obj.bound_from_ = bound_from;
