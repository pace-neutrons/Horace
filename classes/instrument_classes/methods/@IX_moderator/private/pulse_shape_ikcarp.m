function y=pulse_shape_ikcarp(pp,ei,t)
% Calculate normalised Ikeda-Carpenter function
%
%   >> [dt,tav]=pulse_shape_ikcarp(pp,ei,t)
%
% Input:
% -------
%   pp          Arguments for Ikeda-Carpenter moderator
%                   [tauf,taus,R] (times in microseconds)
%   ei          Incident energy (meV) (scalar)
%   t           Array of times at which to evaluate pulse shape (microseconds)
%
% Output:
% -------
%   y           Height of pulse shape. Normalised so pulse has unit area

y = ikcarp (t, pp(1), pp(2), pp(3));
