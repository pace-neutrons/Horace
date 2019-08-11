function [tauf,taus,R]=ikcarp_param_convert(pp,ei)
% Convert pulse parameters to tauf, taus, R for parameterised Ikeda-Carpenter model
%
%   >> [tauf,taus,R]=ikcarp_param_convert(pp)
%
% Input:
% ------
%   pp          Pulse model arguments 
%                   p(1)    Effective distance (m) of for computation
%                          of FWHH of Chi-squared function at Ei
%                          (Typical value 0.03 - 0.06; theoretically 0.028
%                           for hydrogen)
%                   p(2)    Slowing down decay time (microseconds) 
%                          (Typical value 25)
%                   p(3)    Characteristic energy for swapover to storage
%                          (Typical value is 200meV)
%
%   ei          Incident energy (meV) (array or scalar)
%
% Output:
% -------
%   tauf        Epithermal decay time (microseconds) 
%   taus        Slowing down decay time (microseconds) 
%   R           Slowing down fraction

tauf=1166.47*pp(1)./sqrt(ei);
taus=pp(2)*ones(size(ei));
R=exp(-ei/pp(3));
