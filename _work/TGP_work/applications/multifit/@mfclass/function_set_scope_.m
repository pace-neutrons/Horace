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

% Change status
% Clear functions
S_fun = fun_replace (obj.get_fun_props_, isfore, 'all');

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
obj = obj.set_constraints_props_ (S_con);
