function de(w,xlo,xhi,ylo,yhi)
% DE Draws a plot of error bars for a 1D dataset
%
%   de(w)
%   de(w,xlo,xhi)
%   de(w,xlo,xhi,ylo,yhi)

% Check spectrum is not an array
if length(w)>1
    error ('This function only plots a single 1D dataset - check length of spectrum array')
end

if (nargin==1)
    de (d1d_to_spectrum(w));
elseif (nargin==3)
    de (d1d_to_spectrum(w),xlo,xhi);
elseif (nargin==5)
    de (d1d_to_spectrum(w),xlo,xhi,ylo,yhi);
else
    error ('Wrong number of arguments to DE')
end