function [fwhh,xmax,xlo,xhi] = skew_gauss_fwhh (sig, alf)
% Find the FWHH of askew Gaussian
%
%   >> [fwhh,xlo,xhi] = ikcarp_fwhh (tauf, taus, R)
%
% Input:
% ------
%   sig     Standard deviation
%   alf     Assymetry paraeter in the range [-Inf,Inf]. If alf=0 then
%          the function reduces to a Gaussian; if alf>0 skewed to larger
%          tail for positive x; if alf<0 skewed to negative x.
%
% Output:
% -------
%   fwhh    Full width half height (us)
%   xmax    Position of maximum
%   xlo     Position of lower half height
%   xhi     Position of upper half height


% Find the maximum
[xmax,ymax] = fminbnd(@(x)(-skew_gauss(x,0,sig,alf)), -2*sig, 2*sig,...
    optimset('TolX',1e-12,'Display','off'));
ymax=-ymax;     % as inverted the function

% Get half height positions
xlo = fzero(@(x)(skew_gauss(x,0,sig,alf)-0.5*ymax), [xmax-2*sig,xmax],...
    optimset('Display','off'));

xhi = fzero(@(x)(skew_gauss(x,0,sig,alf)-0.5*ymax), [xmax,xmax+2*sig],...
    optimset('Display','off'));

fwhh = xhi-xlo;
