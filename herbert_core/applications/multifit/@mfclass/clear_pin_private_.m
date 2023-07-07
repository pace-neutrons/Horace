function obj = clear_pin_private_ (obj, isfore, args)
% Clear foreground/background function parameter lists
%
%   >> obj = clear_pin_private_(obj, isfore, args)
%
% Set for all functions
%   args = {}        % All parameters cleared
%
% Set for one or more specific function(s)
%   args = {ifun}


% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)


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
%     mess = ['Cannot clear ', fun_type, 'ground function parameters before the function(s) have been set.'];
%     return
% end

% Parse input arguments
% ---------------------
switch numel(args)
  case 0
    ifun = 'all';
  case 1
    ifun = args{1};
  otherwise
    error('HORACE:clear_pin_private:invalid_argument', ...
          'Check number of input arguments');
end

% Now check validity of input
% ---------------------------
ifun = indices_parse (ifun, nfun, 'Function');

% All arguments are valid, so populate the output object
% ------------------------------------------------------
% Update the parameters and clear float status where number of parameters change
[Sfun, clr] = pin_alter (obj.get_fun_props_, isfore, ifun);

% Now clear constraints properties
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
