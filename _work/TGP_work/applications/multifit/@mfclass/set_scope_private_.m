function obj = set_scope_private_(obj, isfore, set_local)
% Set the scope of foreground or background functions to global or local
% Functions are cleared if the scope is altered.
%
%   >> obj = set_scope_private_(obj, isfore, set_local)
%
% Input:
% ------
%   isfore      True if foreground functions, false if background functions
%   set_local   If true:  sets local functions
%               If false: sets global functions


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


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

% Clear functions, insert dummy ones as required, and change scope
if set_local
    nfun = obj.ndatatot_;
else
    nfun = min(1,obj.ndatatot_);    % 0 or 1
end
Sfun = functions_remove (obj.get_fun_props_, isfore, 'all');
Sfun = functions_append (Sfun, isfore, nfun);
if isfore
    Sfun.foreground_is_local_ = set_local;
else
    Sfun.background_is_local_ = set_local;
end

% Clear any constraints that involve the functions to be cleared
if isfore
    Scon = constraints_remove(obj.get_constraints_props_, obj.np_, obj.nbp_, 'all', []);
else
    Scon = constraints_remove(obj.get_constraints_props_, obj.np_, obj.nbp_, [], 'all');
end

% Rebuild the object
obj = obj.set_fun_props_ (Sfun);
obj = obj.set_constraints_props_ (Scon);
