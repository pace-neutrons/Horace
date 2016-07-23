function obj = constraints_remove (obj_in, np_, nbp_, ind, indb)
% Compress entries in the constraints properties to remove the indicated functions
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
%               bound_to_res_
%               ratio_res_
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
%               bound_to_res_
%               ratio_res_


% Fill output with default structure
obj = obj_in;

% Parse input
all_fore = (ischar(ind) && strcmp(ind,'all'));
all_back = ischar(indb) && strcmp(indb,'all');
if all_fore && all_back
    obj = constraints_init (0,0);
elseif all_fore
    ind = 1:numel(np_);
elseif all_back
    indb = 1:numel(nbp_);
end

% Return if nothing to do
if (numel(ind)+numel(indb))==0
    return
end

% Get logical arrays of function and parameters to keep
fkeep = true(numel(np_) + numel(nbp_),1);
indfun=[ind(:);numel(np_)+indb(:)];    % get linear function index
fkeep(indfun) = false;

npp=[np_, nbp_];
pkeep = replicate_logarray (fkeep, npp);

% Retain only required parameters
obj.free_ = obj.free_(pkeep);
obj.bound_ = obj.bound_(pkeep);
obj.bound_to_ = obj.bound_to_(pkeep);
obj.ratio_ = obj.ratio_(pkeep);

% Now clear parameters that were bound to removed parameters
ic = ismember(obj.bound_to_,find(~pkeep));  % *** faster ways to do this: remove zeros; also case of no bound
obj.bound_(ic) = false;
obj.bound_to_(ic) = 0;
obj.ratio_(ic) = 0;

% Need to update the linear parameter indicies of entries in obj.bound_to_
indpar = nonzeros(obj.bound_to_);
indpar_new = indpar_remove (indpar, np_, nbp_, ind, indb);
obj.bound_to_(obj.bound_) = indpar_new;

% Resolve bindings ratios to independent parameters
[obj.bound_to_res_,obj.ratio_res_,ok] = binding_resolve (obj.bound_to_,obj.ratio_);
if ~ok, error('Logic problem - contact T.G.Perring'), end   % should be OK - as started from a valid set


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
