function [obj, ok, mess] = binding_add (obj_in, np_, nbp_, ipb, ifunb, ipf, ifunf, R)
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
%               bound_to_res_
%               ratio_res_
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
%               bound_to_res_
%               ratio_res_
%
%   ok      True if bindings are valid, false if not
%   mess    Empty string if ok; error message if not


% Fill output with default structure
obj = obj_in;

% Return if nothing to do
if numel(ipb)==0
    ok = true;
    mess = '';
    return
end

% Convert parameter indicies into linear lists
iind = parfun2ind (ipf, ifunf, np_, nbp_);    % independent parameters (column vector)
ibnd = parfun2ind (ipb, ifunb, np_, nbp_);    % parameter which will be bound (column vector)

% Get the last occurence of a bound parameter in the list - it might be that it is bound twice
% i.e. there is an implicit clear
[~,ix] = unique(ibnd,'legacy');
iind = iind(ix);
ibnd = ibnd(ix);

% Update bindings
if ~any(ismember(ibnd,[nonzeros(obj.bound_to_);iind])) && all(obj.bound_to_(iind)==0)
    % Catch simple case that all new bound parameters (1) do not have any parameters bound
    % to them, and (2) are bound to independent parameters. This means that the resolving of the
    % bindings is trivial. Note that we have to include the proposed new bindings as well as
    % the current bindings in these checks; this is done by having ismember(ibnd,iind)
    % appearing in the first check.
    obj.bound_(ibnd) = true;
    obj.bound_to_(ibnd) = iind;
    obj.ratio_(ibnd) = R(ix);
    obj.bound_to_res_(ibnd) = iind;
    obj.ratio_res_(ibnd) = R(ix);
    ok = true;
    mess = '';
else
    % Treat in most general case
    % Concatenate existing and new bindings, get last occurrence
    ibnd = [find(obj.bound_);ibnd];
    iind = [obj.bound_to_(obj.bound_);iind];
    ratio = [obj.ratio_(obj.bound_);R];
    [~,ix] = unique(ibnd,'legacy');
    ibnd = ibnd(ix);
    iind = iind(ix);
    ratio = ratio(ix);
    % Repopulate bindings arrays
    nptot = size(obj.bound_,1);
    obj.bound_ = false(nptot,1);
    obj.bound_to = zeros(nptot,1);
    obj.ratio_ = zeros(nptot,1);
    obj.bound_(ibnd) = true;
    obj.bound_to_(ibnd) = iind;
    obj.ratio_(ibnd) = ratio;
    [obj.bound_to_res_,obj.ratio_res_,ok] = binding_resolve (obj.bound_to_,obj.ratio_);
    if ok
        mess = '';
    else
        mess = 'One or more parameters indirectly bound to themselves';
    end
end
