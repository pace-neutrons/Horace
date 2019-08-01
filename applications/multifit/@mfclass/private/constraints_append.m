function Scon = constraints_append (Scon_in, np_, nbp_, np, nbp)
% Append default entries to the constraints properties for additional functions.
% Expands the arrays in the constraints properties structure.
%
% Logically equivalent to constraints_insert with insert at the ends of the
% foreground and background positions
%
%   >> Scon = constraints_append (Scon_in, np_, nbp_, np, nbp)
%
% Input:
% ------
%   Scon_in Constraints structure: fields are 
%               bound_
%               bound_to_
%               bound_to_res_
%               ratio_
%               ratio_res_
%
%   np_     Array of number of foreground parameters in each function in the
%          underlying definition of the constraints structure (row vector)
%
%   nbp_    Array of number of background parameters in each function in the
%          underlying definition of the constraints structure (row vector)
%
%   np      Number of foreground parameters in each function to append (row vector)
%           The length of the array np gives the number of foreground functions
%          to append.
%           If empty (i.e. []), then no foreground functions are appended
%
%   nbp     Number of background parameters in each function to append (row vector)
%           The length of the array nbp gives the number of background functions
%          to append.
%           If empty (i.e. []), then no background functions are appended
%
% Output:
% -------
%   Scon     Constraints structure on output: fields are 
%               bound_
%               bound_to_
%               bound_to_res_
%               ratio_
%               ratio_res_


% Original author: T.G.Perring
%
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)


nptot = sum(np_);
nbptot = sum(nbp_);
ind = nptot*ones(1,numel(np));
indb = (nptot+nbptot)*ones(1,numel(nbp));

Scon = constraints_insert (Scon_in, np_, nbp_, ind, np, indb, nbp);
