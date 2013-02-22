function [table,t_av]=sampling_table(moderator,ei,npnt)
% Create lookup table from which to create random sampling of moderator function
%
%   >> [a,t_av]=sampling_table(moderator,ei)       % sampling_table for ei (default number of points)
%   >> [a,t_av]=sampling_table(moderator,ei,npnt)  % with specified number of points (npnt>=2)
%
% Input:
% -------
%   moderator   IX_fermi_chopper object
%   ei          Incident energy (mev)
%   npnt        Number of points in lookup table.
%               If omitted, set to 50
%
% Output:
% -------
%   a           Look-up table to convert a random number from uniform distribution
%              in the range 0 to 1 into reduced time deviation 0 <= t_red <= 1
%              Convert to true time t = t_av * (t_red/(1-t_red))
%   t_av        First moment of pulse shape (microseconds) 

npnt_default=50;

if nargin==2
    npnt=npnt_default;
elseif npnt<2
    error('Check number of sampling points in the table to be constructed')
end

model=moderator.pulse_model;
if strcmp(model,'ikcarp')           % Raw Ikeda Carpenter
    [table,t_av]=sampling_table_ikcarp(moderator.pp,ei,npnt);
elseif strcmp(model,'ikcarp_param') % Ikeda-Carpenter with parametrised tauf, taus, R
    [table,t_av]=sampling_table_ikcarp_param(moderator.pp,ei,npnt);
else
    error('Unrecognised pulse model')
end
