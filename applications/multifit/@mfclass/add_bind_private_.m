function [ok, mess, obj] = add_bind_private_ (obj, isfore, args)
% Add bindings between parameters for foreground/background functions
%
%   >> [ok, mess, obj] = add_free_private_(obj, isfore, args)
%
% Set for all functions
%   args = {}           % Do nothing
%   args = {bind}       % bind is a cell array of binding descriptors i.e.
%                       % i.e. bind = {b1,b2,...} as below
%                       % (bind can also be a numerical array size [n,5])
%   args = {b1, b2,...} % b1,b2... is each a binding descriptor (a cell array
%                         that contains numeric scalars or arrays)
%
% Set for one or more specific function(s)
%   args = {ifun}               % ifun is a numeric scalar or row vector
%   args = {ifun, bind}
%   args = {ifun, b1, b2,...}


% Original author: T.G.Perring
%
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)


if isfore
    nfun = numel(obj.fun_);
else
    nfun = numel(obj.bfun_);
end

% Parse input arguments
% ---------------------
if numel(args)>=1 && isnumeric(args{1})
    ifun = args{1};
    bind = args(2:end);
else
    ifun = 'all';
    bind = args;
end

% Now check validity of input
% ---------------------------
[ok,mess,ifun] = indicies_parse (ifun, nfun, 'Function');
if ~ok, return, end

[ok,mess,ipb,ifunb,ipf,ifunf,R] = bind_parse(obj.np_,obj.nbp_,isfore,ifun,bind);
if ~ok, return, end
if ~isempty(mess), disp(mess), end

% All arguments are valid, so populate the output object
% ------------------------------------------------------
% Update the constraints
[S_con,ok,mess] = binding_add (obj.get_constraints_props_, obj.np_, obj.nbp_, ipb, ifunb, ipf, ifunf, R);

% Update the object
obj = obj.set_constraints_props_ (S_con);
