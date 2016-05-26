function obj = free_alter (obj_in, np_, nbp_, isfore, indfun, pfree)
% Fix/free parameters
%
%   >> obj = free_alter (obj_in, np_, nbp_, isfore, indfun, pfree)
%
% If a parameter is made free, then any parameters which are bound to it are
% also made free, whether directly or indirectly. That is, a parameter which is
% has not been bound to another parameter if fixed (freed) will fix (free) all
% parameter that are bound to it. Similarly, a bound parameter
% that is fixed (freed) also makes the independenent parameter to which it is bound
% a fixed (free) parameter, and other any parameters which are also bound to that
% independent parameter.
%
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
%   isfore  True if foreground functions, false if background functions
%   indfun  Row vector if indicies of functions to which elements of
%          pfree refer
%   pfree   Cell array of logical row vectors, where the number of elements
%          of the ith vector equals the number of parameters for the
%          function given by ind(i), and with elements =true for free
%          parameters, =false for fixed parameters
%
% Output:
% -------
%   obj     Constraints structure on output: fields are
%               free_
%               bound_
%               bound_to_
%               ratio_
%               bound_from_
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
free = cell2mat(pfree)';

% Find instances of where there is a change of fix/free status
ix = (obj.free_(ind)~=free);

for j=ind(ix)'
    % I think we can make this parallel - check at some point ***
    if obj.bound_(j)
        indep = obj.bound_to_(j);   % the independent parameter
        bound = logical(obj.bound_from_(:,indep));   % parameters that are bound to the independent parameter
        if obj.free_(j)             % currently free, want to fix
            obj.free_(indep) = false;
            obj.free_(bound) = false;
        else
            obj.free_(indep) = true;
            obj.free_(bound) = true;
        end
    else
        bound = logical(obj.bound_from_(:,j));   % parameters that are bound to the independent parameter
        if obj.free_(j)             % currently free, want to fix
            obj.free_(j) = false;
            obj.free_(bound) = false;
        else
            obj.free_(j) = true;
            obj.free_(bound) = true;
        end
    end
end


%------------------------------------------------------------------------------
function ix = pindex (ind, np)
npoff = [0,cumsum(np(1:end-1))];
ix = replicate_iarray(npoff(ind),np(ind)) + sawtooth_iarray(np(ind));
