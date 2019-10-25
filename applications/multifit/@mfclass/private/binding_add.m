function [Scon, ok, mess] = binding_add (Scon_in, np_, nbp_, ipb, ifunb, ipf, ifunf, R)
% Bind parameters
%
%   >> Scon = binding_add (Scon_in, np_, nbp_, ipb, ifunb, ipf, ifunf, R)
%
% If a parameter is already bound, then that binding will be replaced
%
% Input:
% ------
%   Scon_in Constraints structure: fields are 
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
%   Scon    Constraints structure on output: fields are 
%               bound_
%               bound_to_
%               ratio_
%               bound_to_res_
%               ratio_res_
%
%   ok      True if bindings are valid, false if not
%   mess    Empty string if ok; error message if not


% Original author: T.G.Perring
%
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)


% Fill output with default structure
Scon = Scon_in;

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
if ~any(ismember(ibnd,[nonzeros(Scon.bound_to_);iind])) && all(Scon.bound_to_(iind)==0)
    % Catch simple case that all new bound parameters (1) do not have any parameters bound
    % to them, and (2) are bound to independent parameters. This means that the resolving of the
    % bindings is trivial. Note that we have to include the proposed new bindings as well as
    % the current bindings in these checks; this is done by having ismember(ibnd,iind)
    % appearing in the first check.
    Scon.bound_(ibnd) = true;
    Scon.bound_to_(ibnd) = iind;
    Scon.ratio_(ibnd) = R(ix);
    Scon.bound_to_res_(ibnd) = iind;
    Scon.ratio_res_(ibnd) = R(ix);
    ok = true;
    mess = '';
else
    % Treat in most general case
    % Concatenate existing and new bindings, get last occurrence
    ibnd = [find(Scon.bound_);ibnd];
    iind = [Scon.bound_to_(Scon.bound_);iind];
    ratio = [Scon.ratio_(Scon.bound_);R];
    [~,ix] = unique(ibnd,'legacy');
    ibnd = ibnd(ix);
    iind = iind(ix);
    ratio = ratio(ix);
    % Repopulate bindings arrays
    nptot = size(Scon.bound_,1);
    Scon.bound_ = false(nptot,1);
    Scon.bound_to = zeros(nptot,1);
    Scon.ratio_ = zeros(nptot,1);
    Scon.bound_(ibnd) = true;
    Scon.bound_to_(ibnd) = iind;
    Scon.ratio_(ibnd) = ratio;
    [Scon.bound_to_res_,Scon.ratio_res_,ok] = binding_resolve (Scon.bound_to_,Scon.ratio_);
    if ok
        mess = '';
    else
        mess = 'One or more parameters indirectly bound to themselves';
    end
end
