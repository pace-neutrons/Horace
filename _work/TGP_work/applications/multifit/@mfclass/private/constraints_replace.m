function obj = constraints_replace (obj_in, np_, nbp_, ind, np, indb, nbp)
% Replace entries in constraints properties with defaults for replacement functions.
% Expands the arrays in the constraints properties section.
%
%   >> obj = constraints_replace (obj_in, np_, nbp_, ind, np, indb, nbp)
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
%   ind     Indicies of the foreground functions to be replaced (row vector)
%           One index per function, in the range 1:numel(obj.fun_)
%           If empty, then no foreground functions replaced
%   np      Array of number of foreground parameters in each replacement function
%         (row vector)
%   indb    Indicies of the background functions to be inserted (row vector)
%           One index per function, in the range 1:numel(obj.bfun_) (row vector)
%           If empty, then no background functions replaced
%   nbp     Array of number of background parameters in each replacement function
%         (row vector)
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
if (numel(ind)+numel(indb))==0
    return
end

% Remove entries for the indicated functions
obj = constraints_remove (obj, np_, nbp_, ind, indb);

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

obj = constraints_insert (obj, np_new_, nbp_new_, ind_insert, np, indb_insert, nbp);
