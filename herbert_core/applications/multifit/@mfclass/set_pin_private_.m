function obj = set_pin_private_ (obj, isfore, args)
% Set foreground/background function parameter lists
%
%   >> obj = set_pin_private_(obj, isfore, args)
%
% Set for all functions
%   args = {pin}        % Row vector (applies to all) or cell array (one per function)
%
% Set for one or more specific function(s)
%   args = {ifun, free}


% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)


if isfore
    fun_type = 'fore';
    fun = obj.fun_;
    nfun = numel(obj.fun_);
else
    fun_type = 'back';
    fun = obj.bfun_;
    nfun = numel(obj.bfun_);
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
switch numel(args)
  case 0 % Trivial case of no input arguments; just return without doing anything
    return;
  case 1
    ifun = 'all';
    pin=args{1};
  case 2
    ifun = args{1};
    pin = args{2};
  otherwise
    error('HORACE:set_pin_private:invalid_argument', ...
          'Check number of input arguments');
end

% Now check validity of input
% ---------------------------
ifun = indices_parse (ifun, nfun, 'Function');

[pin,np] = pin_parse (pin,fun(ifun));

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

end
