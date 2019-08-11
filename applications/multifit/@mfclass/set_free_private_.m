function [ok, mess, obj] = set_free_private_ (obj, isfore, args)
% Set which foreground/background function parameters are free and which are fixed
%
%   >> [ok, mess, obj] = set_free_private_(obj, isfore, args)
%
% Set for all functions
%   args = {free}      % Row vector (applies to all) or cell array (one per function)
%
% Set for one or more specific function(s)
%   args = {ifun, free}


% Original author: T.G.Perring
%
% $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)


if isfore
    fun_type = 'fore';
    nfun = numel(obj.fun_);
    np = obj.np_;
else
    fun_type = 'back';
    nfun = numel(obj.bfun_);
    np = obj.nbp_;
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
%     mess = ['Cannot set fixed/free status of parameters of ', fun_type, 'ground function(s) before the function(s) have been set.'];
%     return
% end

% Parse input arguments
% ---------------------
if numel(args)==1
    ifun = 'all';
    free=args{1};
elseif numel(args)==2
    ifun = args{1};
    free = args{2};
else
    ok = false;
    mess = 'Check number of input arguments';
    return
end

% Now check validity of input
% ---------------------------
[ok,mess,ifun] = indicies_parse (ifun, nfun, 'Function');
if ~ok, return, end

[ok,mess,free] = free_parse (free, np(ifun));
if ~ok, return, end

% All arguments are valid, so populate the output object
% ------------------------------------------------------
% Update the function structure
Sfun = free_alter (obj.get_fun_props_, isfore, ifun, free);

% Update the object
% -----------------
obj = obj.set_fun_props_ (Sfun);
