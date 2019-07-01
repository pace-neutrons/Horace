function [moderator_out, pars_out] = refine_moderator_strip_pars...
    (moderator_in, modshape, pars_in)
% Take parameters and sqw object and realign the crystal, stripping parameters
%
%   >> [moderator_out, pars_out] = refine_moderator_strip_pars...
%                                       (moderator_in, modshape, pars_in)
%
% Input:
% ------
%   moderator_in    Moderator object to be updated (IX_moderator object)
%
%   modshape        Moderator refinement constants. Structure with fields:
%                   - pulse_model   Pulse shape model for the moderator pulse
%                                  shape whose parameters will be refined
%                   - pin           Initial pulse shape parameters
%                   - ei            Incident energy for pulse shape calculation
%                                  (this will be the common ei for all the
%                                  sqw objects)
%
%   pars_in         Numeric vector of parameter values for fitting function
%                  e.g. [A,js,gam] as intensity, exchange, lifetime, together
%                  with moderator parameters for refinement of moderator
%
% Output:
% -------
%   moderator_out   Updated moderator object (IX_moderator object)
%   pars_out        Parameters stripped of moderator refinement parameters


% Strip out moderator refinement parameters
npmod = numel(modshape.pin);
pars_out = pars_in(1:end-npmod);
pp = pars_in(end-npmod+1:end);

% Get moderator pulse shape lookup table for current moderator parameters
moderator_out = moderator_in;
moderator_out.pulse_model = modshape.pulse_model;
moderator_out.pp = pp;
moderator_out.energy = modshape.ei;
