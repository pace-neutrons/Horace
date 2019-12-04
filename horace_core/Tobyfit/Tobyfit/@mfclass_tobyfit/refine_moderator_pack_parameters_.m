function [ok, mess, obj, modshape] = refine_moderator_pack_parameters_ (obj)
% Alter the foreground function parameter, free/fix and bindings arguments for moderator refinement
%
%   >> [ok, mess, obj, modshape] = refine_moderator_pack_parameters_ (obj)
%
% Input:
% ------
%   obj         Fitting object
%               Properties include refine_moderator, a structure with fields:
%           pulse_model Name of moderator pulse shape model
%           pin         Initial pulse shape parameters (row vector)
%           free        Logical row vector of zeros and ones (row vector)
%
% Output:
% -------
%   obj         Fitting object with parameters updated to allow for moderator
%              refinement: (1) additional parameters for moderator parameters,
%              and (2) bindings so that these additional parameters are global
%              over all data sets.
%
%   modshape    Moderator refinement parmaeters that need to be passed to the
%              fitting function:
%           pulse_model Pulse shape model for the moderator pulse shape whose
%                      parameters will be refined
%           pin         Initial pulse shape parameters
%           ei          Incident energy for pulse shape calculation (this
%                      will be the common ei for all the sqw objects)


mod_opts = obj.refine_moderator;

% Check that the incident energies are all the same (might have been changed
% since set_refine_moderator was called)
if iscell(obj.data)     % might be a single sqw object
    wsqw = cell2mat_obj(cellfun(@(x)x(:),obj.data,'UniformOutput',false));
else
    wsqw = obj.data;
end
[efix,~,ok,mess] = get_efix(wsqw);
if ~ok
    mess=['Moderator refinement: ',mess];
    return
end

% Get the foreground parameters
fun0 = obj.fun;
pin0_obj = obj.pin_obj;
free0 = obj.free;
bind0 = obj.bind;

% Append moderator refinement parameter values
pin_obj = pin0_obj;
for i=1:numel(pin0_obj)
    pin_obj(i).p = [pin0_obj(i).p, mod_opts.pin];
end
pin = arrayfun(@(x)x.plist,pin_obj,'UniformOutput',false);

% Append fix/free status of crystal refinement parameters
if ~iscell(free0)
    free = [free0,mod_opts.free];  % single function
else
    free = cellfun (@(x)[x,mod_opts.free], free0, 'UniformOutput', false);
end

% Alter bindings
% All the refinement parameters are bound to the first foreground function values
np = obj.np;
nfun = numel(obj.fun);
npadd = numel(mod_opts.pin);

bind = bind0;
if nfun>1
    [ipb,ifb] = ndgrid(1:npadd,2:nfun);
    ipb = ipb + repmat(np(2:end),npadd,1);
    bind = [bind; [ipb(:),ifb(:),ipb(:),ones(npadd*(nfun-1),1),ones(npadd*(nfun-1),1)]];
end

% Change fit object
obj = obj.set_fun (fun0, pin, 'free', free, 'bind', bind);

% Fill moderator refinement argument to be passed to multifit
modshape.pulse_model = mod_opts.pulse_model;
modshape.pin = mod_opts.pin;
modshape.ei = efix;

ok = true;
mess = '';
