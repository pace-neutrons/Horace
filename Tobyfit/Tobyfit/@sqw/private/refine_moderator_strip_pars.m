function [pars_out, moderator, buffer_out] = refine_moderator_strip_pars...
    (pars_in, modshape, buffer_in)
% Take parameters and sqw object and realign the crystal, stripping parameters
%
%   >> [table, t_av, fwhh, profile, buffer_out, pars_out] = ...
%           refine_moderator_strip_pars (modshape, buffer_in, pars_in)
%
% Input:
% ------
%   pars_in     Numeric vector of parameter values for fitting function
%              e.g. [A,js,gam] as intensity, exchange, lifetime, together
%              with moderator parameters for refinement of moderator
%
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
% Output:
% -------
%   pars_out    Parameters stripped of moderator refinement parameters
%   moderator   IX_moderator object for current pulse shape parameters
%   buffer_out  Buffer structure updated to hold new entries


% Strip out moderator refinement parameters
npmod = numel(modshape.pin);
pars_out = pars_in(1:end-npmod);
pp = pars_in(end-npmod+1:end);

% Get moderator pulse shape lookup table for current moderator parameters
% (could be made more efficient by buffering)
moderator = IX_moderator (0, 0, modshape.pulse_model, pp);
moderator.energy = modshape.ei;

% Update buffer
% (Currently a dummy operation, as not implemented moderator buffering yet)
buffer_out = buffer_in;
