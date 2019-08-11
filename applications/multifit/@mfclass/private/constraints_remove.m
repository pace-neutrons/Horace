function Scon = constraints_remove (Scon_in, np_, nbp_, ind, indb)
% Remove entries from the constraints properties for the indicated functions.
% Compresses the arrays in the constraints properties structure.
% Any parameters that were bound to parameters that are removed become unbound.
%
%   >> Scon = constraints_remove (Scon_in, np_, nbp_, ind, indb)
%
% Input:
% ------
%   Scon_in Constraints structure: fields are 
%               bound_
%               bound_to_
%               ratio_
%               bound_to_res_
%               ratio_res_
%
%   np_     Array of number of foreground parameters in each function in the
%          underlying definition of the constraints structure (row vector)
%
%   nbp_    Array of number of background parameters in each function in the
%          underlying definition of the constraints structure (row vector)
%
%   ind     Array of indicies of the foreground functions to be removed (row vector)
%           One index per function, in the range 1:numel(Scon.fun_)
%           If empty (i.e. []), then no foreground functions removed
%           For all foreground functions, set ind to 'all'
%
%   indb    Array of indicies of the background functions to be removed (row vector)
%           One index per function, in the range 1:numel(Scon.bfun_)
%           If empty (i.e. []), then no background functions removed
%           For all background functions, set indb to 'all'
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
% $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)


% Fill output with default structure
Scon = Scon_in;

% Parse input
if ischar(ind) && strcmpi(ind,'all')
    ind = 1:numel(np_);
elseif ~isnumeric(ind)
    error('Logic error. Contact developers')
end
    
if ischar(indb) && strcmpi(indb,'all')
    indb = 1:numel(nbp_);
elseif ~isnumeric(ind)
    error('Logic error. Contact developers')
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
Scon.bound_ = Scon.bound_(pkeep);
Scon.bound_to_ = Scon.bound_to_(pkeep);
Scon.ratio_ = Scon.ratio_(pkeep);

% Now clear parameters that were bound to removed parameters
ic = ismember(Scon.bound_to_,find(~pkeep));  % *** faster ways to do this: remove zeros; also case of no bound
Scon.bound_(ic) = false;
Scon.bound_to_(ic) = 0;
Scon.ratio_(ic) = 0;

% Need to update the linear parameter indicies of entries in Scon.bound_to_
indpar = nonzeros(Scon.bound_to_);
indpar_new = indpar_remove (indpar, np_, nbp_, ind, indb);
Scon.bound_to_(Scon.bound_) = indpar_new;

% Resolve bindings ratios to independent parameters
[Scon.bound_to_res_,Scon.ratio_res_,ok] = binding_resolve (Scon.bound_to_,Scon.ratio_);
if ~ok, error('Logic error. Contact developers'), end   % should be OK - as started from a valid set


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
