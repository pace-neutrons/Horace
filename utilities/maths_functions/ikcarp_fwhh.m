function [fwhh,xmax,xlo,xhi] = ikcarp_fwhh (tauf, taus, R)
% Find the FWHH of an Ikeda-Carpenter function
%
%   >> [fwhh,xlo,xhi] = ikcarp_fwhh (tauf, taus, R)
%
% Input:
% ------
%   tauf    Fast decay time (us)
%   taus    Slow decay time (us)
%   R       Weight of storage term (0<=R<=1)
%
% Output:
% -------
%   fwhh    Full width half height (us)
%   xmax    Position of maximum
%   xlo     Position of lower half height
%   xhi     Position of upper half height


% Find the maximum
[xmax,ymax] = fminbnd(@(x)(-ikcarp(x,tauf,taus,R)), 0.1*tauf, 5*(tauf+taus),...
    optimset('TolX',1e-12,'Display','off'));
ymax=-ymax;     % as inverted the function

% Get half height positions
xlo = fzero(@(x)(ikcarp(x,tauf,taus,R)-0.5*ymax), 0.5*xmax,...
    optimset('Display','off'));

xhi = fzero(@(x)(ikcarp(x,tauf,taus,R)-0.5*ymax), [xmax,xmax+2*taus+tauf],...
    optimset('Display','off'));

fwhh = xhi-xlo;
