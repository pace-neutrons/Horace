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


% Original author: T.G.Perring
%
% $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)


if isfore
    fun_type = 'fore';
    nfun = numel(obj.fun_);
else
    fun_type = 'back';
    nfun = numel(obj.bfun_);
end

% % Check there are function(s)
% % ---------------------------
% if nfun==0
%     ok = false;
%     mess = ['Cannot free parameters of ', fun_type, 'ground function(s) before the function(s) have been set.'];
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
% Update the functions structure
Sfun = free_alter (obj.get_fun_props_, isfore, ifun);

% Update the object
% -----------------
obj = obj.set_fun_props_ (Sfun);
