function [table,t_av]=sampling_table_ikcarp(pp,ei,npnt,fast)
% Create lookup table from which to create random sampling of moderator function
%
%   >> [a,t_av]=sampling_table_ikcarp(pp,ei,npnt)
%   >> [a,t_av]=sampling_table_ikcarp(pp,ei,npnt,fast)
%
% Input:
% -------
%   pp          Arguments for Ikeda-Carpenter moderator
%                   [tauf,taus,R] (times in microseconds)
%   ei          Incident energy (mev)
%   npnt        Number of points in lookup table
%   fast        [Optional] flag: if true, use faster but less accurate algorithm
%
% Output:
% -------
%   table       Look-up table to convert a random number from uniform distribution
%              in the range 0 to 1 into reduced time deviation 0 <= t_red <= 1
%              Convert to true time t = t_av * (t_red/(1-t_red)) (column vector).
%   t_av        First moment of pulse shape (microseconds) 
%
% Because t_red=1 corresponds to t=Inf, the maximum area is slightly less 
% than unity. This means that if the table is used on the assumption that
% the array corresponds to the full area range 0 to 1, then this effectively means
% that the Ikeda-Carpenter function has been set to zero for times greater
% than that corresponding to the maximum area.


area=linspace(0,0.999,npnt)';
if nargin==3 || ~fast
    [table,t_av] = area_to_t_ikcarp (area, pp(1), pp(2), pp(3));
else
    [table,t_av] = area_to_t_ikcarp2 (area, pp(1), pp(2), pp(3));
end
