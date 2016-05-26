function obj = constraints_remove (obj_in, np_, nbp_, ind, indb)
% Compress entries in the constraints properties to remove the indicated functions
% Any parameters that are bound to parameters that are to be removed are set
% to free and unbound status.
%
%   >> obj = constraints_remove (obj_in, np_, nbp_, ind, indb)
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
%   ind     Array of indicies of the foreground functions to be removed (row vector)
%           One index per function, in the range 1:numel(obj.fun_)
%           If empty, then no foreground functions removed
%           For all foreground functions, set ind to 'all'
%   indb    Array of indicies of the background functions to be removed (row vector)
%           One index per function, in the range 1:numel(obj.bfun_)
%           If empty, then no background functions removed
%           For all background functions, set indb to 'all'
%
% Output:
% -------
%   obj     Constraints structure on output: fields are 
%               free_
%               bound_
%               bound_to_
%               ratio_
%               bound_from_


% Fill output with default structure
obj = obj_in;

% Parse input
if ischar(ind) && strcmp(ind,'all')
    ind = 1:numel(np_);
end
if ischar(indb) && strcmp(indb,'all')
    indb = 1:numel(nbp_);
end

% Return if nothing to do
if (numel(ind)+numel(indb))==0
    return
end

% Get logical arrays of function and parameters to keep
fkeep = true(numel(np_) + numel(nbp_),1);
indfun=[ind(:),numel(np_)+indb(:)];    % get linear function index
fkeep(indfun) = false;

npp=[np_, nbp_];
pkeep = replicate_logarray (fkeep, npp);

% Get (non-sparse) list of all parameters that will remain and which are bound to ones
% that will be removed.
ifree = logical(full(sum(obj.bound_from_(:,~pkeep),2)));    % the elements are unique because a parameter can only be bound to one other
ifree(~pkeep) = false;  % to reduce from all parameters that are bound to parameters that will be removed, to just those that will remain

% Assign new contents to the locations for parameters that will remain
obj.free_(ifree) = true;    % previously bound parameters may already be free, but force anyway
obj.bound_(ifree) = false;  % now no longer bound
obj.bound_to_(ifree) = 0;
obj.ratio_(ifree) = NaN;

% Retain only required parameters
obj.free_ = obj.free_(pkeep);
obj.bound_ = obj.bound_(pkeep);
obj.bound_to_ = obj.bound_to_(pkeep);
obj.ratio_ = obj.ratio_(pkeep);
obj.bound_from_ = obj.bound_from_(pkeep,pkeep);

% Need to update the linear parameter indicies of entries in obj.bound_to_ and obj.bound_from_
indpar = nonzeros(obj.bound_to_);
indpar_new = indpar_remove (indpar, np_, nbp_, ind, indb);
obj.bound_to_(obj.bound_) = indpar_new;

indpar = nonzeros(obj.bound_from_);
indpar_new = indpar_remove (indpar, np_, nbp_, ind, indb);
obj.bound_from_(find(obj.bound_from_)) = indpar_new;


%--------------------------------------------------------------------------------------------------
function indpar_new = indpar_remove (indpar, np, nbp, ind, indb)
% Transform the linear parameter indicies to those after the indicated
% functions have been removed

% Get parameter and function indicies
[ip, ifun] = ind2parposfun (indpar, np, nbp);

% Foreground functions to keep
nf = numel(np);
keep=true(nf,1);
keep(ind)=false;

% Background functions to keep
nbf = numel(nbp);
bkeep=true(nbf,1);
bkeep(indb)=false;

% Function indicies after removal
ifunlook = zeros(nf+nbf,1);
ifunlook([keep;bkeep]) = (1:nf+nbf-numel(ind)-numel(indb))';
ifun_new = ifunlook(ifun);

% Recompute linear parameter indicies
indpar_new = parposfun2ind (ip, ifun_new, np(keep), nbp(bkeep));
