function [table,t_av]=sampling_table_ikcarp(pp,ei,npnt)
% Create lookup table from which to create random sampling of moderator function
%
%   >> [a,t_av]=sampling_table_ikcarp(pp,ei,npnt)
%
% Input:
% -------
%   pp          Arguments for Ikeda-Carpenter moderator
%                   [tauf,taus,R] (times in microseconds)
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

area=linspace(0,0.999,npnt);
[table,t_av] = area_to_t_ikcarp (area, pp(1), pp(2), pp(3));
