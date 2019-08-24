function w = width (obj, fac)
% Get full width of distribution
%
%   >> w = width (obj)
%   >> w = width (obj, fac)
%
% Input:
% ------
%   obj     pdf_table object
%   fac     Fraction of full jeight at which to determine the width (0 to 1)
%           Default: 0.5
%
% Output:
% -------
%   w       Full width


if nargin==1
    fac=0.5;    % default is fwhh
end

x = obj.x_;
f = obj.f_;
fref = fac*obj.fmax_;

ilo = find(f>fref, 1);
if ilo>1
    xlo = (x(ilo-1)*(f(ilo)-fref) + x(ilo)*(fref-f(ilo-1))) / (f(ilo)-f(ilo-1));
else
    xlo = obj.x_(1);
end

ihi = find(f>fref, 1, 'last');
if ihi<numel(x)
    xhi = (x(ihi)*(fref-f(ihi+1)) + x(ihi+1)*(f(ihi)-fref)) / (f(ihi)-f(ihi+1));
else
    xhi = x(end);
end

w = xhi - xlo;
