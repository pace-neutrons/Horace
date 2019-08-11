function [width,xmax,xlo,xhi] = ikcarp_fwhh (tauf, taus, R, frac)
% Find the width of Ikeda-Carpenter function at a given fraction of height
%
%   >> [fwhh,xlo,xhi] = ikcarp_fwhh (tauf, taus, R)         % half-height
%   >> [fwhh,xlo,xhi] = ikcarp_fwhh (tauf, taus, R, frac)
%
% Input:
% ------
%   tauf    Fast decay time (us)
%   taus    Slow decay time (us)
%   R       Weight of storage term (0<=R<=1)
% Optionally:
%   frac    Fraction of peak height at which to compute width (Default=0.5)
%
% Output:
% -------
%   width   Width of the interval between x values of frac times peak height (us)
%   xmax    Position of maximum
%   xlo     Position of lower position of frac times peak height
%   xhi     Position of upper position of frac times peak height


if nargin==3
    frac = 0.5;
end

% Find the maximum
[xmax,ymax] = fminbnd(@(x)(-ikcarp(x,tauf,taus,R)), 0.1*min(tauf,taus), 5*(tauf+taus),...
    optimset('TolX',1e-12,'Display','off'));
ymax=-ymax;     % as inverted the function

% Get fractional height position for x < xmax:
xlo = fzero(@(x)(ikcarp(x,tauf,taus,R)-frac*ymax), [0,xmax],...
    optimset('Display','off'));

% Get fractional height position for x > xmax:
x = xmax;
y = ymax;
nmult = 1;
while y >= frac*ymax
    nmult = nmult*2;
    x = x + nmult*(tauf+taus);
    y = ikcarp(x,tauf,taus,R);
end

xhi = fzero(@(x)(ikcarp(x,tauf,taus,R)-frac*ymax), [xmax,x],...
    optimset('Display','off'));

width = xhi-xlo;
