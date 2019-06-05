function [y,t] = ikcarp_pulse_shape (pp, t)
% Calculate normalised Ikeda-Carpenter function
%
%   >> [y,t] = ikcarp_pulse_shape (pp, t)
%
% Input:
% -------
%   pp          Arguments for Ikeda-Carpenter moderator
%                   [tauf,taus,R] (times in microseconds)
%
%   t           Array of times at which to evaluate pulse shape (microseconds)
%               If empty, uses a suitable set of points
%
% Output:
% -------
%   y           Pulse shape. Normalised so pulse has unit area
%
%   t           If input was not empty, same as imput argument
%               If input was empty, the default set of points


if isempty(t)
    npnt = 500;
    t = ikcarp_pdf_xvals (npnt, pp(1), pp(2));
end
y = ikcarp (t, pp(1), pp(2), pp(3));
