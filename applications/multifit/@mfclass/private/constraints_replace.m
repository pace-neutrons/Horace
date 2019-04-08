function Scon = constraints_replace (Scon_in, np_, nbp_, ind, np, indb, nbp)
% Replace entries in the constraints properties with defaults for replacement functions.
% Alters the arrays in the constraints properties structure.
% Any parameters that were bound to parameters in functions that have been replaced
% become unbound.
%
% Logically equivalent to constraints_remove followed by constraints_insert
%
%   >> Scon = constraints_replace (Scon_in, np_, nbp_, ind, np, indb, nbp)
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
%   ind     Indicies of the foreground functions to be replaced (row vector)
%           One index per function, in the range 1:numel(Scon.fun_)
%           If empty (i.e. []), then no foreground functions replaced
%
%   np      Array of number of foreground parameters in each replacement function
%         (row vector)
%
%   indb    Indicies of the background functions to be inserted (row vector)
%           One index per function, in the range 1:numel(Scon.bfun_) (row vector)
%           If empty (i.e. []), then no background functions replaced
%
%   nbp     Array of number of background parameters in each replacement function
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
% $Revision:: 830 ($Date:: 2019-04-08 16:16:02 +0100 (Mon, 8 Apr 2019) $)


% Fill output with default structure
Scon = Scon_in;

% Return if nothing to do
if (numel(ind)+numel(indb))==0
    return
end

% Remove entries for the indicated functions
Scon = constraints_remove (Scon, np_, nbp_, ind, indb);

% Insert replacement functions
keep = true(1,numel(np_));
keep(ind) = false;
np_new_ = np_(keep);
ind_insert = cumsum(keep);
ind_insert = ind_insert(~keep);

bkeep = true(1,numel(nbp_));
bkeep(indb) = false;
nbp_new_ = nbp_(bkeep);
indb_insert = cumsum(bkeep);
indb_insert = indb_insert(~bkeep);

Scon = constraints_insert (Scon, np_new_, nbp_new_, ind_insert, np, indb_insert, nbp);
