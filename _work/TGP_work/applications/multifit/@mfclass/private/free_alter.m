function obj = free_alter (obj_in, np_, nbp_, isfore, indfun, pfree)
% Fix/free parameters
%
%   >> obj = free_alter (obj_in, np_, nbp_, isfore, indfun, pfree)
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
%   isfore  True if foreground functions, false if background functions
%   indfun  Row vector if indicies of functions to which elements of
%          pfree refer
%   pfree   Cell array of logical row vectors, where the number of elements
%          of the ith vector equals the number of parameters for the
%          function given by indfun(i), and with elements =true for free
%          parameters, =false for fixed parameters
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
%
%
% It is assumed that the input is consistent with the information in obj
% i.e. the number of parameters for each function, the number of functions etc.


% Fill output with default structure
obj = obj_in;
if isempty(indfun)  % nothing to alter
    return
end

% Convert to column vector of absolute indicies of parameters
if isfore
    ind = pindex(indfun, np_);
else
    ind = sum(np_) + pindex(indfun, nbp_);
end

% Replace entries in object
obj.free_(ind) = cell2mat(pfree)';


%------------------------------------------------------------------------------
function ix = pindex (ind, np)
npoff = [0,cumsum(np(1:end-1))];
ix = replicate_iarray(npoff(ind),np(ind)) + sawtooth_iarray(np(ind));
