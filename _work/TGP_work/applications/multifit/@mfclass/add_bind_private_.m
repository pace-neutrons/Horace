function [ok, mess, obj] = add_bind_private_ (obj, isfore, args)
% Add bindings between parameters for foreground/background functions
%
%   >> [ok, mess, obj] = add_free_private_(obj, isfore, args)
%
% Set for all functions
%   args = {}           % All parameters set to free
%   args = {pfree}      % Row vector (applies to all) or cell array (one per function)
%
% Set for one or more specific function(s)
%   args = {ifun}
%   args = {ifun, pfree}


if isfore
    nfun = numel(obj.fun_);
else
    nfun = numel(obj.bfun_);
end

% Parse input arguments
% ---------------------
if numel(args)>=2 && isnumeric(args{1}) && iscell(args{2})
    ifun = args{1};
    pbind = args(2:end);
else
    ifun = [];
    pbind = args;
end

% Now check validity of input
% ---------------------------
[ok,mess,ifun] = function_indicies_parse (ifun,nfun);
if ~ok, return, end

[ok,mess,ipb,ifunb,ipf,ifunf,R] = pbind_parse(obj.np_,obj.nbp_,isfore,ifun,pbind);
if ~ok, return, end

% All arguments are valid, so populate the output object
% ------------------------------------------------------
% Update the constraints
S_con = binding_add (obj.get_constraints_props_, obj.np_, obj.nbp_, ipb, ifunb, ipf, ifunf, R);

% Update the object
obj = obj.set_constraints_props_ (S_con);
