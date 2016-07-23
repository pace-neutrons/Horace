function [ok, mess, obj] = clear_free_private_ (obj, isfore, args)
% Clear foreground/background function parameters for fitting
%
%   >> [ok, mess, obj] = clear_free_private_(obj, isfore, args)
%
% Set for all functions
%   args = {}           % All parameters set to free
%
% Set for one or more specific function(s)
%   args = {ifun}


if isfore
    nfun = numel(obj.fun_);
    np = obj.np_;
else
    nfun = numel(obj.bfun_);
    np = obj.nbp_;
end

% Parse input arguments
% ---------------------
if numel(args)==0
    ifun = [];
    
elseif numel(args)==1
    ifun = args{1};
    
else
    ok = false;
    mess = 'Check number of input arguments';
    return
end

% Now check validity of input
% ---------------------------
[ok,mess,ifun] = function_indicies_parse (ifun,nfun);
if ~ok, return, end

pfree = mat2cell(true(1,sum(np(ifun))),1,np(ifun));

% All arguments are valid, so populate the output object
% ------------------------------------------------------
% Update the constraints
S_con = free_alter (obj.get_constraints_props_, obj.np_, obj.nbp_, isfore, ifun, pfree);

% Update the object
obj = obj.set_constraints_props_ (S_con);
