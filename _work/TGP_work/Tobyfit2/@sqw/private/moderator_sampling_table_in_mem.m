function [table,t_av,fwhh,profile,buffer_out] =...
    moderator_sampling_table_in_mem (pulse_model,pp,ei,buffer)
% Retrive sampling table output from a buffer, if possible, adding to buffer if necessary
%
%   >> [table,t_av,fwhh,profile,buffer_out] = moderator_sampling_table_in_mem (pulse_model,pin,ei,buffer)
%
%
% Input:
% ------
%   pulse_model Pulse shape model name
%
%   pp          Pulse shape model parameters
%
%   ei          Incident energy (meV)
%
%   buffer_in   Buffer of moderator sampling information. Fields are:
%
%       pulse_model Pulse model name for all moderators
%
%       pp          Array of pulse parameters, size(np,nmod)
%
%       ei          Incident energies (size[1,nmod])
%
%       table       Lookup table of unique moderator entries, size=[npnt,nmod]
%                  where npnt=number of points in lookup table, nmod=number of
%                  unique moderator entries. Elements are time in reduced units.
%                  Use the look-up table to convert a random number from uniform
%                  distribution in the range 0 to 1 into reduced time deviation
%                  0 <= t_red <= 1. Convert to true time using the equation
%                  t = t_av * (t_red/(1-t_red))
%
%       t_av        First moment of time, size=[1,nmod] (seconds, NOT microseconds)
%
%       fwhh        Full width half height, size=[1,nmod] (seconds, NOT microseconds)
%
%       profile     Lookup table of profile, normalised to peak height=1, for
%                  equally spaced intervals of t_red in the range 0 =< t_red =< 1
%
% Output:
% -------
%   table       Lookup table for the input moderator (column vector)
%   t_av        First momnet (seconds, NOT microseconds)
%   fwhh        Full width half height (seconds, NOT microseconds)
%   profile     Profile lookup (column vector)
%   buffer_out  Buffer structure updated to hold new entries
%
%
% Note that if the pulse_model is different to that in the buffer, then the
% buffer will be cleared, as in general the number of parameters in pin will
% be different.


% Check if buffer not empty (assume the buffer has the right structure)
if ~isempty(buffer) && strcmp(pulse_model,buffer.pulse_model)
    % Buffer has at least one entry; check if it is for input parameters
    new_pulse_model = false;
    nmod = numel(buffer.t_av);
    ind = find(all(repmat(pp(:),1,nmod)==buffer.pp,1) & ei==buffer.ei,1);
    if ~isempty(ind)
        table = buffer.table(:,ind);
        t_av = buffer.t_av(ind);
        fwhh = buffer.fwhh(ind);
        profile = buffer.profile(:,ind);
        buffer_out = buffer;
        return
    end
else
    % Buffer needs to be cleared as new moderator model, or no buffer
    new_pulse_model = true;
end

% Moderator not in table, so compute tables
moderator = IX_moderator(0,0,pulse_model,pp);
[table,t_av,fwhh,profile] = sampling_table(moderator,ei,'fast');
t_av = 1e-6*t_av;   % Convert to seconds
fwhh = 1e-6*fwhh;   % Convert to seconds

% Accumulate to buffer or make new buffer
if ~new_pulse_model
    buffer_out.pulse_model = buffer.pulse_model;
    buffer_out.pp      = [buffer.pp,pp(:)];
    buffer_out.ei      = [buffer.ei,ei];
    buffer_out.table   = [buffer.table,table];
    buffer_out.t_av    = [buffer.t_av,t_av];
    buffer_out.fwhh    = [buffer.fwhh,fwhh];
    buffer_out.profile = [buffer.profile,profile];
else
    buffer_out.pulse_model = pulse_model;
    buffer_out.pp      = pp(:);
    buffer_out.ei      = ei;
    buffer_out.table   = table;
    buffer_out.t_av    = t_av;
    buffer_out.fwhh    = fwhh;
    buffer_out.profile = profile;
end
