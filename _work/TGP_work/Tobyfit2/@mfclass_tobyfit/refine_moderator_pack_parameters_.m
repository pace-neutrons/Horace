function [ok, mess, obj, modshape] = refine_moderator_pack_parameters_ (obj, mod_opts)
% Alter the foreground function parameter, free/fix and bindings arguments for moderator refinement
%
%   >> [ok, mess, obj, modshape] = refine_moderator_pack_parameters (obj, mod_opts)
%
% Input:
% ------
%   obj         Fitting object
%
%   mod_opts    Structure with moderator refinement options:
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


% Check that the incident energies are all the same
[efix,~,ok,mess] = get_efix(wsqw);
if ~ok
    mess=['Moderator refinement: ',mess];
    return
end
        
% Get the foreground and background parameters
fun0 = obj.fun;
pin0 = obj.pin;
pfree0 = obj.pfree;
pbind0 = obj.pbind;

% Append moderator refinement parameter values
pin = cellfun (@(x)append_parameters(x,mod_opts.pin), pin0, 'UniformOutput', false);

% Append fix/free status of crystal refinement parameters
pfree = cellfun (@(x)[x,mod_opts.pfree], pfree0, 'UniformOutput', false);

% Alter bindings
% All the refinement parameters are bound to the first foreground function values
pbind = pbind0;
np = numel(mod_opts.pin);
nf = numel(obj.fun);
if nf>1
    [ipb,ifb] = ndgrid(1:np,2:nf);
    pbind = [pbind; [ipb(:),ifb(:),ipb(:),ones(np*(nf-1),1),ones(np*(nf-1),1)]];
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
function pout = append_parameters (pin, p_append)
p = [parameter_get(pin);p_append(:)];
pout = parameter_set(pin, p);
