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
%               bound_to_res_
%               ratio_
%               ratio_res_
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
%               bound_to_res_
%               ratio_
%               ratio_res_


nptot = sum(np_);
nbptot = sum(nbp_);
ind = nptot*ones(1,numel(np));
indb = (nptot+nbptot)*ones(1,numel(nbp));

obj = constraints_insert (obj_in, np_, nbp_, ind, np, indb, nbp);
