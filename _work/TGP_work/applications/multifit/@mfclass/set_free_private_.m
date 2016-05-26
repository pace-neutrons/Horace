function [ok, mess, obj] = set_free_private_ (obj, isfore, args)
% Set which foreground/background function parameters are free and which are bound
%
%   >> [ok, mess, obj] = set_free_private_(obj, isfore, args)
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
    np = obj.np_;
else
    nfun = numel(obj.bfun_);
    np = obj.nbp_;
end

% Parse input arguments
% ---------------------
if numel(args)==0        % neither ifun nor pfree given
    ifun = [];
    pfree = [];
    
elseif numel(args)==1    % one of ifun or pfree
    % There is an ambiguity if the value is 1: is ifun==1 or is pfree=1?
    % Can eliminate case of pfree=1 if not all(np==1)
    % If all(np==1) resolve in favour of pfree
    if iscell(args{1}) || islogical(args{1}) || (islognumscalar(args{1}) && ~isscalar(args{1}))
        ifun = [];
        pfree=args{1};
    elseif isnumeric(args{1})
        if isscalar(args{1}) && args{1}==1 && all(np==1)
            disp('Resolving ambiguity in favour of pfree=[1], not ifun=[1]')
            ifun = [];
            pfree=args{1};
        else
            ifun = args{1};
            pfree = [];
        end
    else
        ok = false;
        mess = 'Check type of input arguments';
        return
    end
    
elseif numel(args)==2    % both of ifun or pfree have been given
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

[ok,mess,pfree]=pfree_parse(pfree,np);
if ~ok, return, end

% All arguments are valid, so populate the output object
% ------------------------------------------------------
% Update the constraints
S_con = free_alter (obj.get_constraints_props_, obj.np_, obj.nbp_, isfore, ifun, pfree);

% Update the object
obj = obj.set_constraints_props_ (S_con);
