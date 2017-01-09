function [table,t_av]=sampling_table_ikcarp_param(pp,ei,npnt,fast)
% Create lookup table from which to create random sampling of moderator function
%
%   >> [table,t_av]=sampling_table_ikcarp(pp,ei,npnt)
%   >> [table,t_av]=sampling_table_ikcarp(pp,ei,npnt,fast)
%
% Input:
% -------
%   pp          Arguments for parametrised Ikeda-Carpenter moderator
%                   pp(1)   Effective distance (m) of for computation
%                          of FWHH of Chi-squared function at Ei
%                          (Typical value 0.03 - 0.06; theoretically 0.028
%                           for hydrogen)
%                   pp(2)   Slowing down decay time (microseconds) 
%                          (Typical value 25)
%                   pp(3)   Characteristic energy for swapover to storage
%                          (Typical value is 200meV)
%   ei          Incident energy (mev)
%   npnt        Number of points in lookup table
%   fast        [Optional] flag: if true, use faster but less accurate algorithm
%
% Output:
% -------
%   table       Look-up table to convert a random number from uniform distribution
%              in the range 0 to 1 into reduced time deviation 0 <= t_red <= 1
%              Convert to true time t = t_av * (t_red/(1-t_red)) (column vector)
%   t_av        First moment of pulse shape (microseconds) 

[tauf,taus,R]=ikcarp_param_convert(pp,ei);
area=linspace(0,0.999,npnt)';
if nargin==3 || ~fast
    [table,t_av] = area_to_t_ikcarp (area, tauf, taus, R);
else
    [table,t_av] = area_to_t_ikcarp2 (area, tauf, taus, R);
end
