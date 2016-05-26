function obj = constraints_insert (obj_in, np_, nbp_, ind, np, indb, nbp)
% Insert default entries in the constraints properties for additional functions.
% Expands the arrays in the constraints properties section.
%
%   >> obj = constraints_insert (obj_in, np_, nbp_, ind, np, indb, nbp)
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
%   ind     Indicies of the foreground functions after which entries for new
%          functions are to be inserted. One index per function, in the range
%          0:numel(obj.bfun_) (row vector)
%           If empty, then no foreground functions inserted
%   np      Array of number of foreground parameters in each function to insert
%         (row vector)
%   indb    Indicies of the background functions after which entries for new
%          functions are to be inserted. One index per function, in the range
%          0:numel(obj.bfun_) (row vector)
%           If empty, then no background functions inserted
%   nbp     Array of number of background parameters in each function to insert
%         (row vector)
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

% Return if nothing to do
if (numel(ind)+numel(indb))==0
    return
end

% Get some parameters
nff_ = numel(np_);
nfb_ = numel(nbp_);
nf_  = nff_ + nfb_;
nptot_ = sum(np_) + sum(nbp_);
nptot = sum(np) + sum(nbp);

% Insert extra terms with default values 
ifun = [1:nf_, ind, indb+nff_];
ifun_rep = replicate_iarray (ifun, [np_, nbp_, np, nbp]);
[~,ix] = sort(ifun_rep);
iy=zeros(numel(ix),1);  % to force column vector
iy(ix) = 1:numel(ix);

obj.free_ = [obj.free_; true(nptot,1)];
obj.bound_ = [obj.bound_; false(nptot,1)];
obj.bound_to_ = [obj.bound_to_; zeros(nptot,1)];
obj.ratio_ = [obj.ratio_; NaN(nptot,1)];

obj.free_ = obj.free_(ix);
obj.bound_ = obj.bound_(ix);
obj.bound_to_ = obj.bound_to_(ix);
obj.ratio_ = obj.ratio_(ix);

[ir,ic,val] = find(obj.bound_from_);
n = nptot_ + nptot;
obj.bound_from_ = sparse(iy(ir),iy(ic),val,n,n,n);

% Update linear parameter indicies
indpar = nonzeros(obj.bound_to_);
indpar_new = indpar_insert (indpar, np_, nbp_, ind, np, indb, nbp);
obj.bound_to_(obj.bound_) = indpar_new;

indpar = nonzeros(obj.bound_from_);
indpar_new = indpar_insert (indpar, np_, nbp_, ind, np, indb, nbp);
obj.bound_from_(find(obj.bound_from_)) = indpar_new;


%--------------------------------------------------------------------------------------------------
function indpar_new = indpar_insert (indpar, np_, nbp_, ind, np, indb, nbp)
% Transform the linear parameter indicies to those after the indicated
% functions have been removed

% Lookup table to convert from current to new function index
nff_ = numel(np_);
nfb_ = numel(nbp_);
nf_  = nff_ + nfb_;
ifun = [1:nf_, ind, indb+nff_];

[~,ix] = sort(ifun);
iy=zeros(numel(ix),1);  % to force column vector
iy(ix) = 1:numel(ix);
ifunlook = iy(1:nf_);

% Get parameter and function indicies
[ip, ifun] = ind2parposfun (indpar, np_, nbp_);

% Function indicies after insertion
ifun_new = ifunlook(ifun);

% Recompute linear parameter indicies
indpar_new = parposfun2ind (ip, ifun_new, [np_,np], [nbp_,nbp]);
