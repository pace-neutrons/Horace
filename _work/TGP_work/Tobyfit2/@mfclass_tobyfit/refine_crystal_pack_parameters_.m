function [ok, mess, obj, xtal] = refine_crystal_pack_parameters_ (obj)
% Alter the foreground function parameter, free/fix and bindings arguments for crystal refinement
%
%   >> [ok, mess, obj, xtal] = refine_crystal_pack_parameters_ (obj, xtal_opts)
%
% Input:
% ------
%   obj         Fitting object
%               Properties include refine_crystal, a structure with fields:
%           alatt   Initial lattice parameters (=[] to use values in sqw objects)
%           angdeg  Initial lattice angles (=[] to use values in sqw objects)
%           rot     Initial rotation vector (rad)
%           urot    x-axis in r.l.u.
%           vrot    Defines y-axis in r.l.u. (in plane of urot and vrot)
%           free    Logical row vector (length=9); true for free parameters
%           fix_alatt_ratio     =true if a,b,c are to be bound
%
% Output:
% -------
%   obj         Fitting object with parameters updated to allow for crystal
%              refinement: (1) additional parameters for lattice parameters,
%              an angles, and crystal orientation; (2) bindings so that these
%              additional parameters are global over all data sets.
%
%   xtal        Crystal refinement parameters that need to be passed to the
%              fitting function:
%           urot    x-axis in r.l.u.
%           vrot    Defines y-axis in r.l.u. (in plane of urot and vrot)
%           ub0     ub matrix for lattice parameters in the input sqw objects
%
% There are nine free parameters in general: 3 lattice parmaeters, 3 lattice angles
% and three orientation angles.


xtal_opts = obj.refine_crystal;

% Check that the lattice parameters are all the same (might have been changed since set_refine_crystal called)
if iscell(obj.data)     % might be a single sqw object
    wsqw = cell2mat_obj(cellfun(@(x)x(:),obj.data,'UniformOutput',false));
else
    wsqw = obj.data;
end
[alatt0,angdeg0,ok,mess] = lattice_parameters(wsqw);
if ~ok
    mess=['Crystal refinement: ',mess];
    error(mess)
end

% Get the foreground parameters
fun0 = obj.fun;
pin0_obj = obj.pin_obj;
free0 = obj.free;
bind0 = obj.bind;

% Append crystal refinement parameter values
opt_pars = [xtal_opts.alatt, xtal_opts.angdeg, xtal_opts.rot];
pin_obj = pin0_obj;
for i=1:numel(pin0_obj)
    pin_obj(i).p = [pin0_obj(i).p, opt_pars];
end
pin = arrayfun(@(x)x.plist,pin_obj,'UniformOutput',false);

% Append fix/free status of crystal refinement parameters
if ~iscell(free0)
    free = [free0,xtal_opts.free];  % single function
else
    free = cellfun (@(x)[x,xtal_opts.free], free0, 'UniformOutput', false);
end

% Alter bindings
% All the refinement parameters are bound to the first foreground function values
% The only complication is if the ratios of the lattice parameters are fixed.
np = obj.np;
nfun = numel(obj.fun);
npadd = numel(opt_pars);

bind = bind0;
if xtal_opts.fix_alatt_ratio
    bind = [bind; [np(1)+2,1,np(1)+1,1,NaN; np(1)+3,1,np(1)+1,1,NaN]];
end
if nfun>1
    [ipb,ifb] = ndgrid(1:npadd,2:nfun);
    ipb = ipb + repmat(np(2:end),npadd,1);
    bind = [bind; [ipb(:),ifb(:),ipb(:),ones(npadd*(nfun-1),1),ones(npadd*(nfun-1),1)]];
end

% Change fit object
obj = obj.set_fun (fun0, pin, 'free', free, 'bind', bind);

% Fill crystal refinement argument to be passed to multifit
xtal.urot=xtal_opts.urot;
xtal.vrot=xtal_opts.vrot;
xtal.ub0 = ubmatrix(xtal.urot,xtal.vrot,bmatrix(alatt0,angdeg0));

ok = true;
mess = '';
