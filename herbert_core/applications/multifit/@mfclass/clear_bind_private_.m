function [ok, mess, obj] = clear_bind_private_ (obj, isfore, args)
% Clear bindings for foreground/background function(s)
%
%   >> [ok, mess, obj] = clear_bind_private_ (obj, isfore, ifun)
%
% Set for all functions
%   args = {}           % All parameters set to free
%
% Set for one or more specific function(s)
%   args = {ifun}


% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)


if isfore
    nfun = numel(obj.fun_);
else
    nfun = numel(obj.bfun_);
end

% Parse input arguments
% ---------------------
switch numel(args)
  case 0
    ifun = 'all';
  case 1
    ifun = args{1};
  otherwise
    ok = false;
    mess = 'Check number of input arguments';
    return
end

% Now check validity of input
% ---------------------------
[ok,mess,ifun] = indicies_parse (ifun, nfun, 'Function');
if ~ok, return, end

% All arguments are valid, so populate the output object
% ------------------------------------------------------
% Now clear constraints properties
if isfore
    ipb = sawtooth_iarray (obj.np_(ifun));
    ifunb = replicate_iarray (ifun, obj.np_(ifun));
else
    ipb = sawtooth_iarray (obj.nbp_(ifun));
    ifunb = replicate_iarray (-ifun, obj.nbp_(ifun));
end

S_con = binding_clear (obj.get_constraints_props_, obj.np_, obj.nbp_, ipb, ifunb);

% Update the object
obj = obj.set_constraints_props_ (S_con);
