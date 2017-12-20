function Scon = constraints_insert (Scon_in, np_, nbp_, ind, np, indb, nbp)
% Insert default entries in the constraints properties for additional functions.
% Expands the arrays in the constraints properties structure.
%
%   >> Scon = constraints_insert (Scon_in, np_, nbp_, ind, np, indb, nbp)
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
%   ind     Indicies of the foreground functions after which entries for new
%          functions are to be inserted. One index per function, in the range
%          0:numel(Scon.fun_) (row vector)
%           If empty (i.e. []), then no foreground functions inserted
%
%   np      Array of number of foreground parameters in each function to insert
%         (row vector)
%
%   indb    Indicies of the background functions after which entries for new
%          functions are to be inserted. One index per function, in the range
%          0:numel(Scon.bfun_) (row vector)
%           If empty (i.e. []), then no background functions inserted
%
%   nbp     Array of number of background parameters in each function to insert
%         (row vector)
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
% $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)


% Fill output with default structure
Scon = Scon_in;

% Return if nothing to do
if (numel(ind)+numel(indb))==0
    return
end

% Get some array lengths
nff_ = numel(np_);
nfb_ = numel(nbp_);
nf_  = nff_ + nfb_;
nptot = sum(np) + sum(nbp);

% Insert extra terms with default values 
ifun = [1:nf_, ind, indb+nff_];
ifun_rep = replicate_iarray (ifun, [np_, nbp_, np, nbp]);
[~,ix] = sort(ifun_rep);

Scon.bound_ = [Scon.bound_; false(nptot,1)];
Scon.bound_to_ = [Scon.bound_to_; zeros(nptot,1)];
Scon.ratio_ = [Scon.ratio_; zeros(nptot,1)];
Scon.bound_to_res_ = [Scon.bound_to_res_; zeros(nptot,1)];
Scon.ratio_res_ = [Scon.ratio_res_; zeros(nptot,1)];

Scon.bound_ = Scon.bound_(ix);
Scon.bound_to_ = Scon.bound_to_(ix);
Scon.ratio_ = Scon.ratio_(ix);
Scon.bound_to_res_ = Scon.bound_to_res_(ix);
Scon.ratio_res_ = Scon.ratio_res_(ix);

% Update linear parameter indicies
indpar = nonzeros(Scon.bound_to_);
indpar_new = indpar_insert (indpar, np_, nbp_, ind, np, indb, nbp);
Scon.bound_to_(Scon.bound_) = indpar_new;

indpar = nonzeros(Scon.bound_to_res_);
indpar_new = indpar_insert (indpar, np_, nbp_, ind, np, indb, nbp);
Scon.bound_to_res_(Scon.bound_) = indpar_new;


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
