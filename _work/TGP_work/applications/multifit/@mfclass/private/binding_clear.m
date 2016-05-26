function obj = binding_clear (obj_in, np_, nbp_, ipb, ifunb)
% Clear selected bound parameters
%
%   >> obj = binding_clear (obj_in, np_, nbp_, ipb, ifunb)
%
% If a parameter is not bound, it is ignored
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
%   ipb     Parameter indicies within the functions for the bound parameters
%          (column vector))
%   ifunb   Function indicies for the bound parameters (column vector):
%               foreground functions: numbered 1,2,3,...numel(np)
%               background functions: numbered -1,-2,-3,...-numel(nbp)
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

% Convert parameter indicies into linear lists
ibnd = parfun2ind (ipb, ifunb, np_, nbp_);

% Clear parameters
bound = obj.bound_(ibnd);
if any(bound)
    iind = obj.bound_to_(ibnd);     % independent parameters
    ibnd = ibnd(bound);     % might be that some parameters are not actually bound
    iind = iind(bound);
    
    obj.bound_(ibnd) = false;
    obj.bound_to_(ibnd) = 0;
    obj.ratio_(ibnd) = NaN;
    i = sub2ind(size(obj.bound_from_), ibnd, iind);
    obj.bound_from_(i) = 0;
end
