function [ok, mess, obj] = clear_fun_private_ (obj, isfore, ifun)
% Clear foreground/background function(s), clearing any corresponding constraints
%
%   >> [ok, mess, obj] = clear_fun_private_ (obj, isfore, ifun)


if isfore
    nfun = numel(obj.fun_);
else
    nfun = numel(obj.bfun_);
end

% Now check validity of input
% ---------------------------
[ok,mess,ifun] = function_indicies_parse (ifun, nfun);
if ~ok, return, end

% All arguments are valid, so populate the output object
% ------------------------------------------------------
% First update the functions
S_fun = fun_replace (obj.get_fun_props_, isfore, ifun);

% Now clear constraints properties
if isfore
    S_con = constraints_replace (obj.get_constraints_props_, obj.np_, obj.nbp_,...
        ifun, zeros(size(ifun)), [], []);
else
    S_con = constraints_replace (obj.get_constraints_props_, obj.np_, obj.nbp_,...
        [], [], ifun, zeros(size(ifun)));
end

% Update the object
obj = obj.set_fun_props_ (S_fun);
obj = obj.set_constraints_props_ (S_con);
