function [w,xmax,xlo,xhi] = width (obj, fac)
% Get full width of distribution
%
%   >> [w,xmax,xlo,xhi] = width (obj)
%   >> [w,xmax,xlo,xhi] = width (obj, fac)
%
% Input:
% ------
%   obj     pdf_table object
%          (See <a href="matlab:help('pdf_table');">pdf_table</a> for details)
%
%   fac     Fraction of full height at which to determine the width (0 to 1)
%           Default: 0.5
%
% Output:
% -------
%   w       Full width at fractional height
%
%   xmax    Position of maximum. If there is more than one point with the
%          same height, this corresponds to the point closest to the middle
%          of xlo and xhi
%
%   xlo     Position of lower position of fac times peak height, obtained
%          by linear interpolation between bracketing points
%          (innermost point)
%
%   xhi     Position of upper position of fac times peak height, obtained
%          by linear interpolation between bracketing points
%          (outermost point)


if ~isscalar(obj)
    error('HERBERT:pdf_table:invalid_argument',...
        'Method only takes a scalar object')
end
if ~obj.filled
    error('HERBERT:pdf_table:uninitialised',...
        'The probability distribution function is not initialised')
end

if numel(obj.x_) > 1
    % Non-delta function distribution
    if nargin==1
        fac=0.5;    % default is fwhh
    end
    
    x = obj.x_;
    f = obj.f_;
    fref = fac*obj.fmax_;
    
    % Find peak limits
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
    
    % Find peak centre
    xmid = 0.5*(xlo+xhi);
    
    ind = find(f==obj.fmax_);   % could be two or more equally high points
    dx = abs(x(ind)-xmid);
    ix = find((dx==min(dx)));
    xmax = sum(x(ind(ix)))/numel(ix);
    
else
    % Special case of a single delta function[w,xmax,xlo,xhi]
    w = 0;
    xmax = obj.x;
    xlo = xmax;
    xhi = xmax;
end

end
