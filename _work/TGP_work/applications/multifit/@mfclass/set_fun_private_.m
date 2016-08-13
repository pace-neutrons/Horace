function [ok, mess, obj] = set_fun_private_ (obj, isfore, args)
% Set foreground/background function or functions
%
%   >> [ok, mess, obj] = set_fun_private_ (obj, isfore, args)
%
% Set all functions
%   args = {@fhandle, pin}
%   args = {@fhandle, pin, pfree}
%   args = {@fhandle, pin, pfree, pbind}
%   args = {@fhandle, pin, 'pfree', pfree, 'pbind', pbind}
%
% Set a particular function or set of functions
%   args = {ifun, @fhandle, pin,...}    % ifun can be scalar or row vector


if isfore
    islocal = obj.foreground_is_local_;
    nfun = numel(obj.fun_);
else
    islocal = obj.background_is_local_;
    nfun = numel(obj.bfun_);
end

% Parse input arguments
% ---------------------
[ok,mess,ifun,fun,pin,pfree,pbind] = function_parse (args{:});
if ~ok, return, end

% Now check validity of input
% ---------------------------
[ok,mess,ifun] = function_indicies_parse (ifun,nfun);
if ~ok, return, end

[ok,mess,fun] = function_handles_parse(fun,size(ifun),islocal);
if ~ok, return, end

[ok,mess,np,pin] = plist_parse(pin,fun);
if ~ok, return, end

[ok,mess,pfree]=pfree_parse(pfree,np);
if ~ok, return, end

if isfore
    [ok,mess,ipb,ifunb,ipf,ifunf,R] = pbind_parse(np,obj.nbp_,isfore,ifun,pbind);
else
    [ok,mess,ipb,ifunb,ipf,ifunf,R] = pbind_parse(obj.np_,np,isfore,ifun,pbind);
end
if ~ok, return, end
if ~isempty(mess), disp(mess), end

% All arguments are valid, so populate the output object
% ------------------------------------------------------
% First update the functions
S_fun = fun_replace (obj.get_fun_props_, isfore, ifun, fun, pin, np);

% Now change constraints properties to accommodate the new functions
if isfore
    S_con = constraints_replace (obj.get_constraints_props_, obj.np_, obj.nbp_, ifun, np, [], []);
else
    S_con = constraints_replace (obj.get_constraints_props_, obj.np_, obj.nbp_, [], [], ifun, np);
end

% Update the constraints themselves
S_con = free_alter (S_con, S_fun.np_, S_fun.nbp_, isfore, ifun, pfree);
[S_con,ok,mess] = binding_add (S_con, S_fun.np_, S_fun.nbp_, ipb, ifunb, ipf, ifunf, R);

% Update the object
obj = obj.set_fun_props_ (S_fun);
obj = obj.set_constraints_props_ (S_con);
