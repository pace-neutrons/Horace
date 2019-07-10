function [ok, mess, obj] = set_fun_private_ (obj, isfore, args)
% Set foreground/background function or functions
%
%   >> [ok, mess, obj] = set_fun_private_ (obj, isfore, args)
%
% Set all functions:
%   args = {fun}
%   args = {fun, pin}
%   args = {fun, pin, free}
%   args = {fun, pin, free, bind}
%   args = {fun, pin, 'free', free, 'bind', bind}
%
% Set a particular function or set of functions:
%   args = {ifun, fun, pin,...}    % ifun can be scalar or row vector


% Original author: T.G.Perring
%
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)


if isfore
    fun_type = 'fore';
    nfun = numel(obj.fun_);
else
    fun_type = 'back';
    nfun = numel(obj.bfun_);
end

% Trivial case of no input arguments; just return without doing anything
if numel(args)==0
    ok = true;
    mess = '';
    return
end

% % Check there is data
% % -------------------
% if isempty(obj.data_)
%     ok = false;
%     mess = ['Cannot set ', fun_type, 'ground function(s) before data has been set.'];
%     return
% end

% Parse input arguments
% ---------------------
[ok,mess,ifun,fun,present,pin,free,bind] = args_parse_set_fun (args{:});
if ~ok, return, end

% First deal with functions structure
% -----------------------------------
% Now check validity of input
[ok,mess,ifun] = indicies_parse (ifun, nfun, 'Function');
if ~ok, return, end

[ok,mess,fun] = fun_parse(fun,size(ifun));
if ~ok, return, end

if present.pin
    [ok,mess,pin,np] = pin_parse(pin,fun);
    if ~ok, return, end
else
    np = zeros(size(fun));  % need np for clearing constraints
end

if present.free
    [ok,mess,free]=free_parse(free,np);
    if ~ok, return, end
end

% All arguments are valid, so populate the output object
[Sfun, clr_fun] = fun_alter (obj.get_fun_props_, isfore, ifun, fun);

if present.pin
    [Sfun, clr_pin] = pin_alter (Sfun, isfore, ifun, pin, np);
else
    clr_pin = false(1,nfun);
end

if present.free
    Sfun = free_alter (Sfun, isfore, ifun, free);
end

% Now deal with constraints structure
% -----------------------------------
% If the functions have changed or the number of parameters has been changed,
% then the constraints arrays need to be cleared accordingly (this must be
% done regardless of whether or not there is an input binding argument)
Scon = obj.get_constraints_props_;

clr = (clr_fun|clr_pin);
if any(clr)
    if isfore
        Scon = constraints_replace (Scon, obj.np_, obj.nbp_,...
            ifun(clr), np(clr), [], []);
    else
        Scon = constraints_replace (Scon, obj.np_, obj.nbp_,...
            [], [], ifun(clr), np(clr));
    end
end

% Now update the bindings if a binding argument was given
if present.bind
    % Check the validity of the input
    [ok, mess, ipb, ifunb, ipf, ifunf, R] = bind_parse (Sfun.np_, Sfun.nbp_,...
        isfore, ifun, bind);
    if ~ok, return, end
    if ~isempty(mess), disp(mess), end
    
    % Now update the constraints themselves
    [Scon,ok,mess] = binding_add (Scon, Sfun.np_, Sfun.nbp_,...
        ipb, ifunb, ipf, ifunf, R);
end

% Update the object
% -----------------
obj = obj.set_fun_props_ (Sfun);
obj = obj.set_constraints_props_ (Scon);
