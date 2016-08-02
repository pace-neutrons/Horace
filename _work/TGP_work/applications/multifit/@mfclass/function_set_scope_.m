function obj = function_set_scope_(obj, isfore, set_local)
% Set the scope of foreground or background functions to global or local
% Functions are cleared if the scope is altered.
%
%   >> obj = function_set_scope_(obj, isfore, set_local)
%
% Input:
% ------
%   isfore      True if foreground functions, false if background functions
%   set_local   If true:  sets local functions
%               If false: sets global functions


% If no change of status, then do nothing
if isfore
    if ~xor(set_local, obj.foreground_is_local_)
        return
    end
else
    if ~xor(set_local, obj.background_is_local_)
        return
    end
end


% Clear functions, and insert dummy ones as required
S_fun = fun_remove (obj.get_fun_props_, isfore, 'all');
if set_local    % *** same algorithm as fun_init - should make common
    nfun = obj.ndatatot_;
else
    if obj.ndatatot_==0
        nfun = 0;
    else
        nfun = 1;
    end
end
S_fun = fun_insert (S_fun, isfore, zeros(1,nfun));
if isfore
    S_fun.foreground_is_local_ = set_local;
else
    S_fun.background_is_local_ = set_local;
end


% Clear any constraints that involve the functions to be cleared
np_ = obj.np_;
nbp_ = obj.nbp_;
if set_local
    % Currently global, changing to local
    if isfore
        if ~isempty(obj.fun_{1})     % function set, so clearing up to do in constraints
            S_con = constraints_remove(obj.get_constraints_props_, np_, nbp_, 'all', []);
        end
    else
        if ~isempty(obj.bfun_{1})    % function set, so clearing up to do in constraints
            S_con = constraints_remove(obj.get_constraints_props_, np_, nbp_, [], 'all');
        end
    end
else
    % Currently local, changing to global
    if isfore
        if ~all(cellfun(@isempty,obj.fun_))     % function(s) set, so clearing up to do in constraints
            S_con = constraints_remove(obj.get_constraints_props_, np_, nbp_,  'all', []);
        end
    else
        if ~all(cellfun(@isempty,obj.bfun_))    % function(s) set, so clearing up to do in constraints
            S_con = constraints_remove(obj.get_constraints_props_, np_, nbp_,  [], 'all');
        end
    end
end

% Rebuild the object
obj = obj.set_fun_props_ (S_fun);
if exist('S_con','var')   % S_con will only exist if there was originally a function defined that is now cleared
    obj = obj.set_constraints_props_ (S_con);
end
