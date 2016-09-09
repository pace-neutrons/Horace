function [ok, mess, obj, modshape] = refine_moderator_pack_parameters_ (obj)
% Alter the foreground function parameter, free/fix and bindings arguments for moderator refinement
%
%   >> [ok, mess, obj, modshape] = refine_moderator_pack_parameters (obj)
%
% Input:
% ------
%   obj         Fitting object
%               Properties include refine_moderator, a structure with fields:
%           pulse_model Name of moderator pulse shape model
%           pin         Initial pulse shape parameters (row vector)
%           pfree       Logical row vector of zeros and ones (row vector)
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

% Check that the incident energies are all the same (might have been changed since set_refine_moderator called)
wsqw = cell2mat_obj(cellfun(@(x)x(:),obj.data,'UniformOutput',false));
[efix,~,ok,mess] = get_efix(wsqw);
if ~ok
    mess=['Moderator refinement: ',mess];
    return
end

% Get the foreground parameters
fun0 = obj.fun;
pin0 = obj.pin;
pfree0 = obj.pfree;
pbind0 = obj.pbind;

% Append moderator refinement parameter values
dummy_mfclass = mfclass;
pin = cellfun (@(x)append_parameters(dummy_mfclass,x,mod_opts.pin), pin0, 'UniformOutput', false);

% Append fix/free status of crystal refinement parameters
pfree = cellfun (@(x)[x,mod_opts.pfree], pfree0, 'UniformOutput', false);

% Alter bindings
% All the refinement parameters are bound to the first foreground function values
np = obj.np;
nfun = numel(obj.fun);
npadd = numel(mod_opts.pin);

pbind = pbind0;
if nfun>1
    [ipb,ifb] = ndgrid(1:npadd,2:nfun);
    ipb = ipb + repmat(np(2:end),npadd,1);
    pbind = [pbind; [ipb(:),ifb(:),ipb(:),ones(npadd*(nfun-1),1),ones(npadd*(nfun-1),1)]];
end

% Change fit object
obj = obj.set_fun (fun0, pin, 'pfree', pfree, 'pbind', pbind);

% Fill moderator refinement argument to be passed to multifit
modshape.pulse_model = mod_opts.pulse_model;
modshape.pin = mod_opts.pin;
modshape.ei = efix;

ok = true;
mess = '';


%----------------------------------------------------------------------------------------
function pout = append_parameters (dummy_mfclass, pin, p_append)
p = [mfclass_gateway_parameter_get(dummy_mfclass, pin); p_append(:)];
pout = mfclass_gateway_parameter_set(dummy_mfclass, pin, p);
