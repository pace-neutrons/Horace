function obj = binding_add (obj_in, np_, nbp_, ipb, ifunb, ipf, ifunf, R)
% Bind parameters
%
%   >> obj = binding_add (obj_in, np_, nbp_, ipb, ifunb, ipf, ifunf, R)
%
% If a parameter is already bound, then that binding will be replaced
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
%   ifunb   Function indicies for the bound parameterd (column vector):
%               foreground functions: numbered 1,2,3,...numel(np)
%               background functions: numbered -1,-2,-3,...-numel(nbp)
%   ipf     Parameter indicies within the functions for the floating parameters
%   ifunf   Function index for the floating parameter(column vector):
%          (column vector))
%               foreground functions: numbered 1,2,3,...numel(np)
%               background functions: numbered -1,-2,-3,...-numel(nbp)   
%   R       Ratio of values of bound/independent parameters (column vector).
%           If to be set by values of initial parameter values, then is NaN;
%          otherwise is finite.
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
iind = parfun2ind (ipf, ifunf, np_, nbp_);    % independent parameters (column vector)
ibnd = parfun2ind (ipb, ifunb, np_, nbp_);    % parameter which will be bound (column vector)

% Must use a for loop as a parameter may appear more than once in iind or ibnd
% The result is that element-by-element operation is not possible
for i = 1:numel(ibnd)
    % If currently bound, clear the current bound_from_ entry
    if obj.bound_(ibnd(i))
        j = obj.bound_to_(ibnd(i));
        obj.bound_from_(ibnd(i),j) = false;
    else
        obj.bound_(ibnd(i)) = true;
    end
    % If asked to bind to a currently bound parameter, get the underlying floating parameter
    if obj.bound_(iind(i))
        j = obj.bound_to_(iind(i));         % parameter to which currently bound
        obj.bound_to_(ibnd(i)) = j;         % 
        obj.ratio_(ibnd(i)) = R(i)*obj.ratio_(iind(i));
        obj.bound_from_(ibnd(i),j) = true;
    else
        % Currently a floating parameter; now bind it
        obj.bound_to_(ibnd(i)) = iind(i);
        obj.ratio_(ibnd(i)) = R(i);
        obj.bound_from_(ibnd(i),iind(i)) = true;
    end
end
