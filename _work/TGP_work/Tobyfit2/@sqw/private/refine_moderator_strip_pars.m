function [table, t_av, fwhh, profile, buffer_out, pars_out] = ...
    refine_moderator_strip_pars (modshape, buffer_in, pars_in)
% Take parameters and sqw object and realign the crystal, stripping parameters
%
%   >> [table, t_av, fwhh, profile, buffer_out, pars_out] = ...
%           refine_moderator_strip_pars (modshape, buffer_in, pars_in)
%
% Input:
% ------
%   modshape    Moderator refinement constants. Structure with fields:
%                   pulse_model Pulse shape model for the moderator pulse shape whose
%                              parameters will be refined
%                   pin         Initial pulse shape parameters
%                   ei          Incident energy for pulse shape calculation (this
%                              will be the common ei for all the sqw objects)
%
%   buffer_in   Buffer of moderator sampling information. See the help to
%               moderator_sampling_table_in_mem for details
%
%   pars_in     Arguments needed by the fit function. Most commonly, a vector of parameter
%              values e.g. [A,js,gam] as intensity, exchange, lifetime. If a more general
%              set of parameters is required by the function, then
%              package these into a cell array and pass that as pars. In the example
%              above then pars = {p, c1, c2, ...} 
%
% Output:
% -------
%   table       Lookup table for the input moderator (column vector)
%   t_av        First momnet (seconds, NOT microseconds)
%   fwhh        Full width half height (seconds, NOT microseconds)
%   profile     Profile lookup (column vector)
%   buffer_out  Buffer structure updated to hold new entries
%   pars_out    Parameters stripped of moderator refinement parameters


% Strip out moderator refinement parameters
npmod = numel(modshape.pin);
dummy_mfclass = mfclass;
ptmp = mfclass_gateway_parameter_get(dummy_mfclass, pars_in);
pars_out = mfclass_gateway_parameter_set(dummy_mfclass, pars_in, ptmp(1:end-npmod));
pp = ptmp(end-npmod+1:end);

% Get moderator lookup table for current moderator parameters
[table,t_av,fwhh,profile,buffer_out] = ...
    moderator_sampling_table_in_mem (modshape.pulse_model,pp,modshape.ei,buffer_in);
