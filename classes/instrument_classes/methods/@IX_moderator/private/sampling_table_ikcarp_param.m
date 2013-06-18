function [table,t_av]=sampling_table_ikcarp_param(pp,ei,npnt)
% Create lookup table from which to create random sampling of moderator function
%
%   >> [a,t_av]=sampling_table_ikcarp(pp,ei,npnt)
%
% Input:
% -------
%   pp          Arguments for parametrised Ikeda-Carpenter moderator
%                   p(1)    Effective distance (m) of for computation
%                          of FWHH of Chi-squared function at Ei
%                          (Typical value 0.03 - 0.06; theoretically 0.028
%                           for hydrogen)
%                   p(2)    Slowing down decay time (microseconds) 
%                          (Typical value 25)
%                   p(3)    Characteristic energy for swapover to storage
%                          (Typical value is 200meV)
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

[tauf,taus,R]=ikcarp_param_convert(pp,ei);
area=linspace(0,0.999,npnt)';
[table,t_av] = area_to_t_ikcarp (area, tauf, taus, R);
