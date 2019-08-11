function [ok, mess, obj] = clear_fun_private_ (obj, isfore, args)
% Clear foreground/background function(s), clearing any corresponding constraints
%
%   >> [ok, mess, obj] = clear_fun_private_ (obj, isfore, args)
%
% Set for all functions
%   args = {}           % All parameters set to free
%
% Set for one or more specific function(s)
%   args = {ifun}


% Original author: T.G.Perring
%
% $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)


if isfore
    fun_type = 'fore';
    nfun = numel(obj.fun_);
else
    fun_type = 'back';
    nfun = numel(obj.bfun_);
end

% % Check there is data
% % -------------------
% if isempty(obj.data_)
%     ok = false;
%     mess = ['Cannot clear ', fun_type, 'ground function(s) before data has been set.'];
%     return
% end

% Parse input arguments
% ---------------------
if numel(args)==0
    ifun = 'all';
elseif numel(args)==1
    ifun = args{1};
else
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
% First update the functions
[Sfun,clr] = fun_alter (obj.get_fun_props_, isfore, ifun);

% Now clear constraints properties - only do for functions which have
% been cleared
Scon = obj.get_constraints_props_;
if any(clr)
    if isfore
        Scon = constraints_remove (Scon, obj.np_, obj.nbp_, ifun(clr), []);
    else
        Scon = constraints_remove (Scon, obj.np_, obj.nbp_, [], ifun(clr));
    end
end

% Update the object
% -----------------
obj = obj.set_fun_props_ (Sfun);
obj = obj.set_constraints_props_ (Scon);
