function [ok, mess, obj] = set_free_private_ (obj, isfore, args)
% Set which foreground/background function parameters are free and which are bound
%
%   >> [ok, mess, obj] = set_free_private_(obj, isfore, args)
%
% Set for all functions
%   args = {pfree}      % Row vector (applies to all) or cell array (one per function)
%
% Set for one or more specific function(s)
%   args = {ifun, pfree}


if isfore
    nfun = numel(obj.fun_);
    np = obj.np_;
else
    nfun = numel(obj.bfun_);
    np = obj.nbp_;
end

% Parse input arguments
% ---------------------
if numel(args)==1
    ifun = [];
    pfree=args{1};
    
elseif numel(args)==2
    ifun = args{1};
    pfree = args{2};
    
else
    ok = false;
    mess = 'Check number of input arguments';
    return
end

% Now check validity of input
% ---------------------------
[ok,mess,ifun] = function_indicies_parse (ifun,nfun);
if ~ok, return, end

[ok,mess,pfree] = pfree_parse (pfree,np(ifun));
if ~ok, return, end

% All arguments are valid, so populate the output object
% ------------------------------------------------------
% Update the constraints
S_con = free_alter (obj.get_constraints_props_, obj.np_, obj.nbp_, isfore, ifun, pfree);

% Update the object
obj = obj.set_constraints_props_ (S_con);
