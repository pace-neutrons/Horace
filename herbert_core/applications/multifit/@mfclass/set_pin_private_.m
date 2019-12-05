function [ok, mess, obj] = set_pin_private_ (obj, isfore, args)
% Set foreground/background function parameter lists
%
%   >> [ok, mess, obj] = set_pin_private_(obj, isfore, args)
%
% Set for all functions
%   args = {pin}        % Row vector (applies to all) or cell array (one per function)
%
% Set for one or more specific function(s)
%   args = {ifun, free}


% Original author: T.G.Perring
%
% $Revision:: 838 ($Date:: 2019-12-05 14:56:03 +0000 (Thu, 5 Dec 2019) $)


if isfore
    fun_type = 'fore';
    fun = obj.fun_;
    nfun = numel(obj.fun_);
else
    fun_type = 'back';
    fun = obj.bfun_;
    nfun = numel(obj.bfun_);
end

% Trivial case of no input arguments; just return without doing anything
if numel(args)==0
    ok = true;
    mess = '';
    return
end

% % Check there are function(s)
% % ---------------------------
% if nfun==0
%     ok = false;
%     mess = ['Cannot set ', fun_type, 'ground function parameters before the function(s) have been set.'];
%     return
% end

% Parse input arguments
% ---------------------
if numel(args)==1
    ifun = 'all';
    pin=args{1};
elseif numel(args)==2
    ifun = args{1};
    pin = args{2};
else
    ok = false;
    mess = 'Check number of input arguments';
    return
end

% Now check validity of input
% ---------------------------
[ok,mess,ifun] = indicies_parse (ifun, nfun, 'Function');
if ~ok, return, end

[ok,mess,pin,np] = pin_parse (pin,fun(ifun));
if ~ok, return, end

% All arguments are valid, so populate the output object
% ------------------------------------------------------
% Update the parameters and clear float status where number of parameters change
[Sfun, clr] = pin_alter (obj.get_fun_props_, isfore, ifun, pin, np);

% Now replace constraints properties with default for functions which have
% a changed number of parameters
Scon = obj.get_constraints_props_;
if any(clr)
    if isfore
        Scon = constraints_replace (Scon, obj.np_, obj.nbp_,...
            ifun(clr), np(clr), [], []);
    else
        Scon = constraints_replace (Scon, obj.np_, obj.nbp_,...
            [], [], ifun(clr), np(clr));
    end
end

% Update the object
% -----------------
obj = obj.set_fun_props_ (Sfun);
obj = obj.set_constraints_props_ (Scon);

