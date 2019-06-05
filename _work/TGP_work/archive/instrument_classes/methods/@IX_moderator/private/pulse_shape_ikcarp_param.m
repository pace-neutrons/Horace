function y=pulse_shape_ikcarp_param(pp,ei,t)
% Calculate normalised Ikeda-Carpenter function
%
%   >> [dt,tav]=pulse_shape_ikcarp(pp,ei,t)
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
%   ei          Incident energy (meV) (scalar)
%   t           Array of times at which to evaluate pulse shape (microseconds)
%
% Output:
% -------
%   y           Height of pulse shape. Normalised so pulse has unit area

[tauf,taus,R]=ikcarp_param_convert(pp,ei);
y = ikcarp (t, tauf, taus, R);
